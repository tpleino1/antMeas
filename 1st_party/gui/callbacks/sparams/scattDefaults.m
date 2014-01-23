function scattDefaults(~, ~, gui, static)
% Reset the S-Param tab to its default values
	
	gui = guidata(gui.window);
	
	% Shorthands
	coeff = static.tabs.settings.units.freq.coeffs(gui.dynamic.units.freq);
	unit = static.tabs.settings.units.freq.units{gui.dynamic.units.freq};
	f = gui.dynamic.original.aut.sParam.freq / coeff;
	
	% Debugging vs real values
	if gui.debug && isempty(f)
		f = (700 : 40 : 1100)' * 1e6 / coeff;
	end
	
	clear coeff;
	
	% Freq. range
	set(gui.sParamTab.settPanel.freqLabel, ...
		'String',	sprintf(static.tabs.sParam.settPanel.freqLabel, unit));
	set(gui.sParamTab.settPanel.freqMinEdit, 'String', num2str(min(f), '%g'));
	set(gui.sParamTab.settPanel.freqMaxEdit, 'String', num2str(max(f), '%g'));
	
	% Graph & Replacement
	set(gui.sParamTab.settPanel.graphSelect, ...
		'Value',	static.tabs.sParam.plotSett.graphType.default);
	set(gui.sParamTab.settPanel.replacementSelect, ...
		'Value',	static.tabs.sParam.plotSett.replacement.default);
	set(gui.sParamTab.settPanel.replacementSelect, 'Enable', 'on');
	
	% Markers
	set(gui.sParamTab.settPanel.markerList, 'String', ...
		[ static.tabs.sParam.settPanel.noneText; ...
			strcat(cellfun(@num2str, num2cell(f), ...
			'UniformOutput', false), [' ', unit]) ]);
	clear unit;
	set(gui.sParamTab.settPanel.markerList, 'Min', 1);
	set(gui.sParamTab.settPanel.markerList, 'Max', length(f));
	set(gui.sParamTab.settPanel.markerList, ...
		'Value',	static.tabs.sParam.plotSett.marker.default);
	
	% Graph
	if ~gui.dynamic.sParam.axesVisible
		cla(gui.sParamTab.graphPanel.axes, 'reset');
		set(gui.sParamTab.graphPanel.axes, 'visible', 'off');
		set(gui.sParamTab.settPanel.popButton, 'enable', 'off');
		gui.sParamTab.graphPanel.legend.enable = false;
		gui.sParamTab.graphPanel.legend.handles = [];
		gui.sParamTab.graphPanel.legend.markers = [];
		gui.sParamTab.graphPanel.legend.text = {};
	end
	
	guidata(gui.window, gui);
	
end