function scattChangeFreq(~, ~, gui, static)
% A callback to validate frequency range and to change the marker list when
% frequency range is changed 
	
	gui = guidata(gui.window);
	
	% Shorthands
	coeff = static.tabs.settings.units.freq.coeffs(gui.dynamic.units.freq);
	unit = static.tabs.settings.units.freq.units{gui.dynamic.units.freq};
	
	% Debugging vs. real values
	if gui.debug	
		freq = (700 : 40 : 1100)' * 1e6 / coeff;
	else
		freq = gui.dynamic.original.aut.sParam.freq / coeff;
	end
	
	% Shorthands
	fMin = abs(str2double(get(gui.sParamTab.settPanel.freqMinEdit, 'String')));
	fMax = abs(str2double(get(gui.sParamTab.settPanel.freqMaxEdit, 'String')));
	
	% Sanity check
	if ~isfinite(fMin) || fMin < min(freq) || fMin > max(freq)
		fMin = min(freq);
	end
	
	if ~isfinite(fMax) || fMax > max(freq) || fMax < fMin
		fMax = max(freq);
	end
	
	f = freq(freq >= fMin);
	f = f(f <= fMax);
	
	% No points in the defined range
	if isempty(f)
		i = find(freq <= fMin, 1, 'last');
		j = find(freq >= fMax, 1, 'first');
		
		if isempty(i) && isempty(j)
			fMin = min(freq);
			fMax = max(freq);
		elseif ~isempty(i) && isempty(j)
			fMin = freq(i);
			fMax = fMin;
		elseif isempty(i) && ~isempty(j)
			fMax = freq(j);
			fMin = fMax;
		else
			fMin = freq(i);
			fMax = freq(j);
		end
		
		f = freq(freq >= fMin);
		f = f(f <= fMax);
	end
	
	% Update dynamic
	gui.dynamic.sParam.freqRange = [fMin fMax];
	
	% Update GUI
	set(gui.sParamTab.settPanel.freqMinEdit, 'String', num2str(fMin, '%g'));
	set(gui.sParamTab.settPanel.freqMaxEdit, 'String', num2str(fMax, '%g'));
	
	% Update marker list
	set(gui.sParamTab.settPanel.markerList, 'String', ...
		[ static.tabs.sParam.settPanel.noneText; ...
			strcat(cellfun(@num2str, num2cell(f), ...
				'UniformOutput', false), [' ', unit]) ]);
	set(gui.sParamTab.settPanel.markerList, 'Min', 1);
	set(gui.sParamTab.settPanel.markerList, 'Max', length(f));
	set(gui.sParamTab.settPanel.markerList, ...
		'Value',		static.tabs.sParam.plotSett.marker.default);
	
	guidata(gui.window, gui);
	
end