function pattPop(~, ~, gui, static)
% Copies currently docked figure as a new figure
	
	gui = guidata(gui.window);
	
	% Copy
	f = figure('Name', static.plotting.figName.patt);
	a = axes('parent', f);
	set(a, 'ActivePositionProperty', 'OuterPosition');
	copyaxes(gui.pattTab.graphPanel.axes, a);
	gui.dynamic.plotting.figures(f-1) = f;
	
	% Docked figure has a legend
	if gui.pattTab.graphPanel.legend.enable
		legend(a, gui.pattTab.graphPanel.legend.markers, ...
			gui.pattTab.graphPanel.legend.text);
	end
	
	guidata(gui.window, gui);
	
end