function inputBrowseFile(~, ~, gui, static, ant, meas)
% A callback to browse for a measurement file, used for each input file
		
	gui = guidata(gui.window);
	
	% Make the browsing easier by 'guessing' the right folder
	switch meas
		case 'horiz'
			antiMeas = 'vert';
		case 'vert'
			antiMeas = 'horiz';
		otherwise
			antiMeas = '';
	end
	
	try
		% Open 'Load File' dialog
		% Use the 'guess'
		if ~isempty(antiMeas) && ~isempty(gui.dynamic.io.(ant).(antiMeas).path)
			[fn, pn, fi] = uigetfile(...
				{ static.tabs.input.io.(meas).ext, ...
					static.tabs.input.io.(meas).desc }, ...
				sprintf(static.tabs.input.io.general.dialogTitle, ...
					static.tabs.input.io.(meas).meas, ...
					static.tabs.input.io.general.antenna.(ant) ), ...
				gui.dynamic.io.(ant).(antiMeas).path );
		else % Use default
			[fn, pn, fi] = uigetfile(...
				{ static.tabs.input.io.(meas).ext, ...
					static.tabs.input.io.(meas).desc }, ...
				sprintf(static.tabs.input.io.general.dialogTitle, ...
					static.tabs.input.io.(meas).meas, ...
					static.tabs.input.io.general.antenna.(ant) ) );
		end

		if fn ~= 0
			str = getFormattedFileName(pn, fn);
		else
			str = static.tabs.input.io.general.clickToBrowse;
			fn = '';
			pn = '';
			fi = 1;
		end
		
	catch err
		if gui.debug
			getReport(err);
		end
		
		str = static.tabs.input.io.general.clickToBrowse;
		fn = '';
		pn = '';
		fi = 1;
	end

	% Update gui & dynamic struct
	set(gui.inputTab.(strcat(ant, 'Panel')).(strcat(meas, 'Edit')), 'String', str);
	
	gui.dynamic.io.(ant).(meas).file = fn;
	gui.dynamic.io.(ant).(meas).path = pn;
	gui.dynamic.io.(ant).(meas).index = fi;
	
	% Enough to calculate something? Set the 
	if ~isempty(gui.dynamic.io.aut.sParam.file) || ...
		~isempty(gui.dynamic.io.aut.horiz.file) || ...
		~isempty(gui.dynamic.io.aut.vert.file)
		e = 'On';
	else
		e = 'Off';
	end
		
	set(gui.inputTab.buttonRow.openButton, 'Enable', e);
	clear e;
	
	guidata(gui.window, gui);
	
end