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

const applyLayout = (layout) => {
  Window.all()
    .filter((window) => window.isVisible())
    .forEach((window) => {
      const title = window.app().name();
      const applicableRule = Object.keys(layout).find((rule) =>
        new RegExp(rule).test(title)
      );
      console.log(`Applicable rule for "${title}": "${applicableRule}"`);

      if (applicableRule !== undefined) {
        layout[applicableRule](window);
      }
    });
};

const devLayout = Object.freeze({
  Alacritty: toArea("main"),
  Firefox: toArea("tall"),
  "Slack|Messenger|Element": toArea("chat"),
  "": toArea("off"),
});

const fullsizeLayout = Object.freeze({
  "": (window) => place(window, slots.full),
});

// Focus apps one after another, so the last ends up active and the ones
// before it stacked beneath it in reverse order.
const focusInOrder = (names) =>
  names.forEach((name) => App.get(name)?.focus());

// Cycle through layouts, like tmux's next-layout.
const layouts = [devLayout, fullsizeLayout];
let currentLayout = -1;
const nextLayout = () => {
  currentLayout = (currentLayout + 1) % layouts.length;
  applyLayout(layouts[currentLayout]);
  focusInOrder(["Firefox", "Alacritty"]);
};

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
