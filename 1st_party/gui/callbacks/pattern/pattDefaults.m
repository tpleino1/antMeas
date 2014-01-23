function pattDefaults(~, ~, gui, static)
% Reset the Pattern tab to its default values

	gui = guidata(gui.window);
	
	% Shorthands
	fCoeff = static.tabs.settings.units.freq.coeffs(gui.dynamic.units.freq);
	fUnit = static.tabs.settings.units.freq.units{gui.dynamic.units.freq};
	pCoeff = static.tabs.settings.units.phase.coeffs(gui.dynamic.units.phase);
	pUnit = static.tabs.settings.units.phase.units{gui.dynamic.units.phase};
	
	f = gui.dynamic.interpolated.freq;
	p = gui.dynamic.interpolated.prim;
	s = gui.dynamic.interpolated.sec;
	
	% Debug values
	if gui.debug && (isempty(f) || isempty(p) || isempty(s))
		f = (700:40:1100)' * 1e6;
		p = (-180:10:180)';
		s = (-180:10:0)';
		% gui.dynamic.enable.horiz = true;
		% gui.dynamic.enable.vert = true;
	end
	
	f = f / fCoeff;
	p = p / pCoeff;
	s = s / pCoeff;
	
	% Shorthands
	choices = struct( ...
		'freq',	{strcat(cellfun(@num2str, num2cell(f), ...
					'UniformOutput', false), [' ', fUnit])}, ...
		'prim',	{strcat(cellfun(@num2str, num2cell(p), ...
					'UniformOutput', false), [' ', pUnit])}, ...
		'seco',	{strcat(cellfun(@num2str, num2cell(s), ...
					'UniformOutput', false), [' ', pUnit])} ...
		);
		
	clear f p s;

	% Graph type
	gui.dynamic.patt.graphType = static.tabs.patt.plotSett.graphType.default;
	set(gui.pattTab.settPanel.graphSelect, ...
		'Value',		gui.dynamic.patt.graphType);
	
	% Second axis vs. overlay
	set(gui.pattTab.settPanel.secondAxisLabel, 'String', ...
		static.tabs.patt.settPanel.secondLabel.options{ ...
			1 + ~(gui.dynamic.patt.graphType > 2)});
	
	% First Axis
	gui.dynamic.patt.firstAxis.options = ...
		static.tabs.patt.plotSett.axis.options;
	gui.dynamic.patt.firstAxis.selected = ...
		static.tabs.patt.plotSett.axis.default;
	set(gui.pattTab.settPanel.firstAxisSelect, ...
		'Value', 		gui.dynamic.patt.firstAxis.selected);
	
	% Second Axis / Overlay
	gui.dynamic.patt.secondAxis.selected = 1;
	gui.dynamic.patt.secondAxis.options = ...
		static.tabs.patt.plotSett.axis.options(... 
			1 : length(static.tabs.patt.plotSett.axis.options) ~= ...
			gui.dynamic.patt.firstAxis.selected);
	set(gui.pattTab.settPanel.secondAxisSelect, ...
		'String',		gui.dynamic.patt.secondAxis.options, ...
		'Value',		gui.dynamic.patt.secondAxis.selected);
	
	% Fixed
	gui.dynamic.patt.fixed.variable = gui.dynamic.patt.secondAxis.options{...
		1 : length(gui.dynamic.patt.secondAxis.options) ~= ...
		gui.dynamic.patt.secondAxis.selected};
	gui.dynamic.patt.fixed.options = ...
		choices.(lower(gui.dynamic.patt.fixed.variable(1:4)));
	gui.dynamic.patt.fixed.selected = 1;
	
	set(gui.pattTab.settPanel.fixedLabel, ...
		'String',		sprintf(static.tabs.patt.settPanel.fixedLabel, ...
							lower(gui.dynamic.patt.fixed.variable)));
	set(gui.pattTab.settPanel.fixedSelect, ...
		'String',		gui.dynamic.patt.fixed.options, ...
		'Value',		gui.dynamic.patt.fixed.selected);
	
	% Polarization
	e = 'off';
	if gui.dynamic.enable.horiz && gui.dynamic.enable.vert
		gui.dynamic.patt.polarization = ...	% Sum powers
			static.tabs.patt.plotSett.polarization.default;	
		e = 'on';
	else % 1: Horiz, 2: Vert
		gui.dynamic.patt.polarization = 1 + ...
			(~gui.dynamic.enable.horiz & gui.dynamic.enable.vert); 
	end
	set(gui.pattTab.settPanel.polarizationSelect, ...
		'Value',		gui.dynamic.patt.polarization);
	set(gui.pattTab.settPanel.polarizationSelect, ...
		'Enable',		e);
	clear e;
	
	% Plot value
	gui.dynamic.patt.value = static.tabs.patt.plotSett.value.default;
	set(gui.pattTab.settPanel.valueSelect, ...
		'Value',		gui.dynamic.patt.value);
	
	% Replacement
	gui.dynamic.patt.replacement = ...
		static.tabs.patt.plotSett.replacement.default;
	set(gui.pattTab.settPanel.replacementSelect, ...
		'Value',		gui.dynamic.patt.replacement);
	
	% Overlay
	if gui.dynamic.patt.graphType > 2
		gui.dynamic.patt.overlay.options = {static.tabs.patt.settPanel.noneText};
		e = 'off';
	else
		gui.dynamic.patt.overlay.options = ...
			choices.(lower(gui.dynamic.patt.secondAxis.options{...
				gui.dynamic.patt.secondAxis.selected}(1:4)));
		e = 'on';
	end
	gui.dynamic.patt.overlay.selected = 1;

	set(gui.pattTab.settPanel.overlayList, ...
		'String',		gui.dynamic.patt.overlay.options, ...
		'Min',			1, ...
		'Max',			length(gui.dynamic.patt.overlay.options), ...
		'Value',		gui.dynamic.patt.overlay.selected, ...
		'Enable',		e ...
		);
	clear e;
	
	% Graph
	if ~gui.dynamic.patt.axesVisible
		cla(gui.pattTab.graphPanel.axes, 'reset');
		set(gui.pattTab.graphPanel.axes, 'visible', 'off');
		set(gui.pattTab.settPanel.popButton, 'enable', 'off');
		gui.pattTab.graphPanel.legend.enable = false;
		gui.pattTab.graphPanel.legend.handles = [];
		gui.pattTab.graphPanel.legend.markers = [];
		gui.pattTab.graphPanel.legend.text = {};
	end
	
	guidata(gui.window, gui);
	
end