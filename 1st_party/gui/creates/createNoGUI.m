function gui = createNoGUI(static, debug)
% Creates the gui struct to be used from cmd.

	gui = struct(...
		'dynamic',	initDynamic(static), ...
		'debug',	debug, ...
		'window',	figure ... 	% for guidata
		);

	guidata(gui.window, gui);

end
