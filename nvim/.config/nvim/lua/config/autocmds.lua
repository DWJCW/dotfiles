-- Autocmds are automatically loaded on the VeryLazy event.
-- The cheat-sheet module owns its commands, deterministic audit, and startup
-- drift warning so the displayed keys and validation rules share one source.

require("config.cheatsheet").setup()
