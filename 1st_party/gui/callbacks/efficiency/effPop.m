function effPop(~, ~, gui, static)
% Copies currently docked figure as a new figure
	
	gui = guidata(gui.window);
	
	% Copy
	f = figure('Name', static.plotting.figName.eff);
	a = axes('parent', f);
	set(a, 'ActivePositionProperty', 'OuterPosition');
	copyaxes(gui.effTab.graphPanel.axes, a);
	set(get(a, 'Title'), 'String', static.plotting.figName.eff);
	gui.dynamic.plotting.figures(f-1) = f;
	
	% Docked figure has a legend
	if gui.effTab.graphPanel.legend.enable
		legend(a, gui.effTab.graphPanel.legend.markers, ...
			gui.effTab.graphPanel.legend.text);
	end
	
	guidata(gui.window, gui);
	
end