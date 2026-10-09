Phoenix.set({
  openAtLogin: true,
});

const gutter = 12;

/* Slots: regions of a screen, as fractions of its visible frame */

const slots = Object.freeze({
  full: { x: 0, y: 0, width: 1, height: 1 },
  top: { x: 0, y: 0, width: 1, height: 1 / 2 },
  bottom: { x: 0, y: 1 / 2, width: 1, height: 1 / 2 },
  left: { x: 0, y: 0, width: 2 / 3, height: 1 },
  topleft: { x: 0, y: 0, width: 2 / 3, height: 1 / 2 },
  bottomleft: { x: 0, y: 1 / 2, width: 2 / 3, height: 1 / 2 },
  right: { x: 2 / 3, y: 0, width: 1 / 3, height: 1 },
  topright: { x: 2 / 3, y: 0, width: 1 / 3, height: 1 / 2 },
  bottomright: { x: 2 / 3, y: 1 / 2, width: 1 / 3, height: 1 / 2 },
});

// Edges on the screen's border get a full gutter and edges shared with
// another slot get half, so neighbouring windows end up one gutter apart.
const span = (origin, length, start, size) => {
  const end = start + size;
  const from = origin + start * length + (start === 0 ? gutter : gutter / 2);
  const to = origin + end * length - (end === 1 ? gutter : gutter / 2);
  return [Math.round(from), Math.round(to - from)];
};

const frameFor = (screen, slot) => {
  const frame = screen.flippedVisibleFrame();
  const [x, width] = span(frame.x, frame.width, slot.x, slot.width);
  const [y, height] = span(frame.y, frame.height, slot.y, slot.height);
  return { x, y, width, height };
};

// Put a window in a slot, on its current screen unless another is given.
const place = (window, slot, screen = window?.screen()) => {
  if (!window || !screen) {
    return;
  }

  const moving = window.screen()?.identifier() !== screen.identifier();
  window.setFrame(frameFor(screen, slot));

  if (moving) {
    // Set again once macOS has registered the window on the new screen, as
    // otherwise its size stays constrained to the old screen's size.
    setTimeout(() => window.setFrame(frameFor(screen, slot)), 50);
  }
};

// Like place, but only sets the rows and keeps the window's current column.
const placeRows = (window, slot) => {
  const screen = window?.screen();

  if (!screen) {
    return;
  }

  const { y, height } = frameFor(screen, slot);
  window.setFrame({ ...window.frame(), y, height });
};

/* Screens: the connected monitors by role */

const isPortrait = (screen) => {
  const { width, height } = screen.frame();
  return height > width;
};

// The tall monitor is the portrait one; the others keep their system order
// (off, then main). Roles without their own monitor share one that exists.
const physicalScreens = () => {
  const all = Screen.all();
  const tall = all.length > 1 ? all.find(isPortrait) : undefined;
  const landscape = all.filter((screen) => screen !== tall);
  const off = landscape[0] ?? all[0];
  const main = landscape[1] ?? off;
  return { main, off, tall: tall ?? main };
};

/* Areas: where layouts send windows. With enough monitors an area is a whole
   screen, otherwise it's a slot on a shared one. */

const at = (screen, slot = slots.full) => ({ screen, slot });

// Indexed by the number of connected monitors, minus one.
const areasByMonitorCount = [
  ({ main }) => ({
    main: at(main, slots.left),
    tall: at(main, slots.right),
    chat: at(main, slots.bottomright),
    off: at(main, slots.topright),
  }),
  ({ main, off }) => ({
    main: at(main, slots.left),
    tall: at(main, slots.right),
    chat: at(off),
    off: at(off),
  }),
  ({ main, tall, off }) => ({
    main: at(main),
    tall: at(tall),
    chat: at(off),
    off: at(off),
  }),
];

const areas = () => {
  const count = Math.min(Screen.all().length, areasByMonitorCount.length);
  return areasByMonitorCount[count - 1](physicalScreens());
};

const toArea = (name) => (window) => {
  const { screen, slot } = areas()[name];
  place(window, slot, screen);
};

/* Layouts: app name patterns mapped to placements, first match wins */

const ruleFor = (layout, window) => {
  const title = window.app().name();
  const applicableRule = Object.keys(layout.rules).find((rule) =>
    new RegExp(rule).test(title)
  );
  console.log(`Applicable rule for "${title}": "${applicableRule}"`);
  return layout.rules[applicableRule];
};

const applyLayout = (layout) => {
  Window.all()
    .filter((window) => window.isVisible())
    .forEach((window) => ruleFor(layout, window)?.(window));
};

const devLayout = Object.freeze({
  name: "Dev",
  rules: {
    Alacritty: toArea("main"),
    Firefox: toArea("tall"),
    "Slack|Messenger|Element": toArea("chat"),
    "": toArea("off"),
  },
  focus: ["Firefox", "Alacritty"],
});

const fullsizeLayout = Object.freeze({
  name: "Fullsize",
  rules: {
    "": (window) => place(window, slots.full),
  },
  focus: ["Firefox", "Alacritty"],
});

// No layout: windows are left where they are, including new ones.
const freeLayout = Object.freeze({
  name: "Free",
  rules: {},
  focus: [],
});

// Focus apps one after another, so the last ends up active and the ones
// before it stacked beneath it in reverse order.
const focusInOrder = (names) =>
  names.forEach((name) => App.get(name)?.focus());

// Briefly show a message in the middle of a screen.
const flash = (text, screen) =>
  Modal.build({
    text,
    duration: 0.5,
    animationDuration: 0,
    weight: 20,
    appearance: "dark",
    origin: (modal) => {
      const frame = screen.visibleFrame();
      return {
        x: frame.x + (frame.width - modal.width) / 2,
        y: frame.y + (frame.height - modal.height) / 2,
      };
    },
  }).show();

// Start in Free, so nothing moves until a layout is picked.
const layouts = [devLayout, fullsizeLayout, freeLayout];
let currentLayout = layouts.indexOf(freeLayout);

const activate = (index) => {
  currentLayout = index;
  // Flash first, and rearrange on the next tick so the notice gets drawn
  // before the slow work of moving and focusing windows.
  flash(layouts[index].name, physicalScreens().main);
  setTimeout(() => {
    applyLayout(layouts[index]);
    focusInOrder(layouts[index].focus);
  }, 0);
};

// Cycle through layouts, like tmux's next-layout.
const nextLayout = () => activate((currentLayout + 1) % layouts.length);

// Re-apply the layout when monitors are (dis)connected, once they've settled:
// macOS fires the event several times while it rearranges them.
let screensChangedTimer;
Event.on("screensDidChange", () => {
  if (layouts[currentLayout] === freeLayout) {
    return;
  }

  clearTimeout(screensChangedTimer);
  screensChangedTimer = setTimeout(() => activate(currentLayout), 1000);
});

// New windows follow the current layout's rules too.
Event.on("windowDidOpen", (window) => {
  if (window.isNormal()) {
    ruleFor(layouts[currentLayout], window)?.(window);
  }
});

const fullscreen = () => {
  const window = Window.focused();

  if (!window) return;

  window.setFullScreen(!window.isFullScreen());
};

/* Keybindings */

Key.on("space", ["shift", "alt", "ctrl"], nextLayout);

Key.on("space", ["ctrl", "alt"], () => place(Window.focused(), slots.full));
Key.on("f", ["ctrl", "alt"], fullscreen);

Key.on("h", ["ctrl", "alt"], () => place(Window.focused(), slots.left));
Key.on("l", ["ctrl", "alt"], () => place(Window.focused(), slots.right));
Key.on("k", ["ctrl", "alt"], () => placeRows(Window.focused(), slots.top));
Key.on("j", ["ctrl", "alt"], () => placeRows(Window.focused(), slots.bottom));

const toScreen = (role) => () =>
  place(Window.focused(), slots.full, physicalScreens()[role]);

Key.on("q", ["ctrl", "alt"], toScreen("off"));
Key.on("w", ["ctrl", "alt"], toScreen("main"));
Key.on("e", ["ctrl", "alt"], toScreen("tall"));
