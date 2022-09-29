const tallMonitor = 1;
const middleMonitor = 2;
const offMonitor = 0;
const gutter = 10;

const devLayout = Object.freeze([
  {
    "Google Chrome": (window) => {
      left(window);
    },
    Code: (window) => {
      left(window);
    },
    Alacritty: (window) => {
      right(window);
    },
    Slack: (window) => {
      bottomright(window);
    },
    Messenger: (window) => {
      bottomright(window);
    },
    "": (window) => {
      topright(window);
    },
  },
  {
    "Google Chrome": (window) => {
      moveToScreen(tallMonitor)(window);
      left(window);
    },
    Code: (window) => {
      moveToScreen(tallMonitor)(window);
      left(window);
    },
    Alacritty: (window) => {
      moveToScreen(tallMonitor)(window);
      right(window);
    },
    "": (window) => {
      moveToScreen(offMonitor)(window);
    },
  },
  {
    "Google Chrome": (window) => {
      moveToScreen(tallMonitor)(window);
    },
    Code: (window) => {
      moveToScreen(middleMonitor)(window);
      left(window);
    },
    Alacritty: (window) => {
      moveToScreen(middleMonitor)(window);
      right(window);
    },
    "": (window) => {
      moveToScreen(offMonitor)(window);
    },
  },
]);

// Unused AtM
const adminLayout = [
  {
    "": (window) => {
      // Screen 0 is always the primary window
      moveToScreen(0)(window);
    },
  },
  {
    "Google Chrome": (window) => {
      moveToScreen(middleMonitor)(window);
      left(window);
    },
    Code: (window) => {
      moveToScreen(middleMonitor)(window);
      left(window);
    },
    Alacritty: (window) => {
      moveToScreen(middleMonitor)(window);
      right(window);
    },
    "": (window) => {
      moveToScreen(offMonitor)(window);
    },
  },
  {
    "Google Chrome": (window) => {
      moveToScreen(middleMonitor)(window);
    },
    Jira: (window) => {
      moveToScreen(tallMonitor)(window);
      top(window);
    },
    Trello: (window) => {
      moveToScreen(tallMonitor)(window);
      top(window);
    },
    Mail: (window) => {
      moveToScreen(tallMonitor)(window);
      bottom(window);
    },
    "": (window) => {
      moveToScreen(offMonitor)(window);
    },
  },
];

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

const topleft = (window) => {
  const screen = window.screen();

  if (!screen) {
    return;
  }

  const frame = screen.flippedVisibleFrame();

  window.setFrame({
    x: frame.x + gutter,
    y: frame.y + gutter,
    width: Math.round(twoThirds(frame.width) - 1.5 * gutter),
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

const bottomleft = (window) => {
  const screen = window.screen();

  if (!screen) {
    return;
  }

  const frame = screen.flippedVisibleFrame();

  window.setFrame({
    x: frame.x + gutter,
    y: Math.round(frame.y + frame.height / 2 + 0.5 * gutter),
    width: Math.round(twoThirds(frame.width) - 1.5 * gutter),
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

const fullsizeAllWindows = () => Screen.main().windows().map(fullsize);

const fullscreen = () => {
  const window = Window.focused();

  if (!window) return;

  window.setFullScreen(!window.isFullScreen());
};

const applyLayout = (layoutScheme) => {
  const screens = Screen.all();
  const layout = layoutScheme[screens.length - 1];

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

const schemes = [devLayout /*, adminLayout*/];
let currentIndex = -1;
const toggleLayout = () => {
  const layoutScheme = schemes[(currentIndex += 1) % schemes.length];
  applyLayout(layoutScheme);
};

const moveToScreen = (index) => (window) => {
  const screen = Screen.all()[index];

  if (screen) {
    const bounds = screen.flippedVisibleFrame();
    window.setFrame({
      x: bounds.x + gutter,
      y: bounds.y + gutter,
      width: bounds.width - 2 * gutter,
      height: bounds.height - 2 * gutter,
    });

    // Hack to make sure the window is on the right monitor before resizing as otherwise the
    // window size will be constrained to the old screen's size.
    setTimeout(moveToScreen.bind(null, index, window), 50);
  }
};

const moveToRelativeSpace = (direction) => () => {
  const window = Window.focused();
  const currentSpace = window.screen().currentSpace();
  const nextSpace =
    direction >= 0 ? currentSpace.next() : currentSpace.previous();
  if (currentSpace && nextSpace) {
    currentSpace.removeWindows([window]);
    nextSpace.addWindows([window]);
  }
};

const focusApp = (name) => () => {
  const app = App.get(name);

  if (app) {
    app.focus();
  }
};

/* Keybindings */

Key.on("space", ["shift", "alt", "ctrl"], toggleLayout);

Key.on("space", ["shift", "alt"], fullsizeFocusedWindow);
Key.on("space", ["shift", "alt", "ctrl", "cmd"], fullsizeAllWindows);
Key.on("f", ["shift", "alt"], fullscreen);

Key.on("h", ["shift", "alt"], () => left(Window.focused()));
Key.on("l", ["shift", "alt"], () => right(Window.focused()));
Key.on("k", ["shift", "alt"], () => top(Window.focused()));
Key.on("j", ["shift", "alt"], () => bottom(Window.focused()));

Key.on("q", ["shift", "alt", "ctrl"], () => topleft(Window.focused()));
Key.on("w", ["shift", "alt", "ctrl"], () => topright(Window.focused()));
Key.on("a", ["shift", "alt", "ctrl"], () => bottomleft(Window.focused()));
Key.on("s", ["shift", "alt", "ctrl"], () => bottomright(Window.focused()));

Key.on("q", ["shift", "alt"], () =>
  moveToScreen(tallMonitor)(Window.focused())
);
Key.on("w", ["shift", "alt"], () =>
  moveToScreen(middleMonitor)(Window.focused())
);
Key.on("e", ["shift", "alt"], () => moveToScreen(offMonitor)(Window.focused()));

Key.on("h", ["shift", "alt", "ctrl"], moveToRelativeSpace(-1));
Key.on("l", ["shift", "alt", "ctrl"], moveToRelativeSpace(1));

Key.on("u", ["shift", "alt"], focusApp("Google Chrome"));
Key.on("i", ["shift", "alt"], focusApp("Code"));
Key.on("o", ["shift", "alt"], focusApp("Alacritty"));
Key.on("p", ["shift", "alt"], focusApp("Slack"));
