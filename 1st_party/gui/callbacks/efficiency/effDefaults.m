function effDefaults(~, ~, gui, static)
% Reset the Efficiency tab to its default values
	
	gui = guidata(gui.window);
	
	% Unit
	gui.dynamic.eff.unit = static.tabs.eff.plotSett.unit.default;
	set(gui.effTab.settPanel.unitSelect, ...
		'Value',	gui.dynamic.eff.unit);
	
	% Replacement
	gui.dynamic.eff.replacement = static.tabs.eff.plotSett.replacement.default;
	set(gui.effTab.settPanel.replacementSelect, ...
		'Value',	gui.dynamic.eff.replacement);
	
	% Graph
	if ~gui.dynamic.eff.axesVisible
		cla(gui.effTab.graphPanel.axes, 'reset');
		set(gui.effTab.graphPanel.axes, 'visible', 'off');
		set(gui.effTab.settPanel.popButton, 'enable', 'off');
		gui.effTab.graphPanel.legend.enable = false;
		gui.effTab.graphPanel.legend.handles = [];
		gui.effTab.graphPanel.legend.markers = [];
		gui.effTab.graphPanel.legend.text = {};
	end
	
	guidata(gui.window, gui);
	
end