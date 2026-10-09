Phoenix.set({
  openAtLogin: true,
});

const mainMonitor = 1;
const offMonitor = 0;
const gutter = 10;

const oneThird = (x) => x / 3;
const twoThirds = (x) => (2 * x) / 3;

const left = (window) => {
  const screen = window.screen();

  if (!screen) {
    return;
  }

  const frame = screen.flippedVisibleFrame();

  window.setFrame({
    x: frame.x + gutter,
    y: frame.y + gutter,
    width: Math.round(twoThirds(frame.width) - 1.5 * gutter),
    height: frame.height - 2 * gutter,
  });
};

const right = (window) => {
  const screen = window.screen();

  if (!screen) {
    return;
  }

  const frame = screen.flippedVisibleFrame();

  window.setFrame({
    x: Math.round(frame.x + twoThirds(frame.width) + 0.5 * gutter),
    y: frame.y + gutter,
    width: Math.round(oneThird(frame.width) - 1.5 * gutter),
    height: frame.height - 2 * gutter,
  });
};

const top = (window) => {
  const screen = window.screen();

  if (!screen) {
    return;
  }

  const frame = screen.flippedVisibleFrame();

  window.setFrame({
    ...window.frame(),
    y: frame.y + gutter,
    height: Math.round(frame.height / 2 - 1.5 * gutter),
  });
};

const bottom = (window) => {
  const screen = window.screen();

  if (!screen) {
    return;
  }

  const frame = screen.flippedVisibleFrame();

  window.setFrame({
    ...window.frame(),
    y: Math.round(frame.y + frame.height / 2 + 0.5 * gutter),
    height: Math.round(frame.height / 2 - 1.5 * gutter),
  });
};

const topright = (window) => {
  const screen = window.screen();

  if (!screen) {
    return;
  }

  const frame = screen.flippedVisibleFrame();

  window.setFrame({
    x: Math.round(frame.x + twoThirds(frame.width) + 0.5 * gutter),
    y: frame.y + gutter,
    width: Math.round(oneThird(frame.width) - 1.5 * gutter),
    height: Math.round(frame.height / 2 - 1.5 * gutter),
  });
};

const bottomright = (window) => {
  const screen = window.screen();

  if (!screen) {
    return;
  }

  const frame = screen.flippedVisibleFrame();

  window.setFrame({
    x: Math.round(frame.x + twoThirds(frame.width) + 0.5 * gutter),
    y: Math.round(frame.y + frame.height / 2 + 0.5 * gutter),
    width: Math.round(oneThird(frame.width) - 1.5 * gutter),
    height: Math.round(frame.height / 2 - 1.5 * gutter),
  });
};

const fullsize = (window) => {
  const screen = window.screen();

  if (!screen) {
    return;
  }

  const frame = screen.flippedVisibleFrame();

  window.setFrame({
    x: frame.x + gutter,
    y: frame.y + gutter,
    width: frame.width - 2 * gutter,
    height: frame.height - 2 * gutter,
  });
};

const fullsizeFocusedWindow = () => fullsize(Window.focused());

const fullscreen = () => {
  const window = Window.focused();

  if (!window) return;

  window.setFullScreen(!window.isFullScreen());
};

const applyLayout = (layoutScheme) => {
  const layout = layoutScheme[Screen.all().length - 1];

  console.log(`Layout: "${Object.keys(layout)}"`);

  Window.all()
    .filter((window) => window.isVisible())
    .forEach((window) => {
      const title = window.app().name();
      const applicableRule = Object.keys(layout).find((rule) =>
        new RegExp(rule).test(title)
      );
      console.log(`Applicable rule for "${title}": "${applicableRule}"`);
      layout[applicableRule](window);
    });
};

const moveToScreen =
  (index, place = fullsize) =>
  (window) => {
    const screen = Screen.all()[index];

    if (!screen) {
      return;
    }

    const bounds = screen.flippedVisibleFrame();
    window.setFrame({
      x: bounds.x + gutter,
      y: bounds.y + gutter,
      width: bounds.width - 2 * gutter,
      height: bounds.height - 2 * gutter,
    });
    place(window);

    // Place again once macOS has registered the window on the new screen, as
    // otherwise its size stays constrained to the old screen's size.
    setTimeout(() => place(window), 50);
  };

const devLayout = Object.freeze([
  {
    Alacritty: left,
    Firefox: right,
    Slack: bottomright,
    Messenger: bottomright,
    "": topright,
  },
  {
    Alacritty: moveToScreen(mainMonitor, left),
    Firefox: moveToScreen(mainMonitor, right),
    "": moveToScreen(offMonitor),
  },
]);

const fullsizeLayout = Object.freeze([{ "": fullsize }, { "": fullsize }]);

// Cycle through layouts, like tmux's next-layout.
const layouts = [devLayout, fullsizeLayout];
let currentLayout = -1;
const nextLayout = () => {
  currentLayout = (currentLayout + 1) % layouts.length;
  applyLayout(layouts[currentLayout]);
};

/* Keybindings */

Key.on("space", ["shift", "alt", "ctrl"], nextLayout);

Key.on("space", ["ctrl", "alt"], fullsizeFocusedWindow);
Key.on("f", ["ctrl", "alt"], fullscreen);

Key.on("h", ["ctrl", "alt"], () => left(Window.focused()));
Key.on("l", ["ctrl", "alt"], () => right(Window.focused()));
Key.on("k", ["ctrl", "alt"], () => top(Window.focused()));
Key.on("j", ["ctrl", "alt"], () => bottom(Window.focused()));

Key.on("q", ["ctrl", "alt"], () => moveToScreen(offMonitor)(Window.focused()));
Key.on("w", ["ctrl", "alt"], () =>
  moveToScreen(mainMonitor)(Window.focused())
);
