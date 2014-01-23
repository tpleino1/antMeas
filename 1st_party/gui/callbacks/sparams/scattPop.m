function scattPop(~, ~, gui, static)
% Copies currently docked figure as a new figure
	
	gui = guidata(gui.window);
	
	% Copy
	f = figure('Name', static.plotting.figName.sParam);
	a = axes('parent', f);
	set(a, 'ActivePositionProperty', 'OuterPosition');
	copyaxes(gui.sParamTab.graphPanel.axes, a);
	set(get(a, 'Title'), 'String', static.plotting.figName.sParam);
	gui.dynamic.plotting.figures(f-1) = f;
	
	% Legend
	if gui.sParamTab.graphPanel.legend.enable
		legend(a, gui.sParamTab.graphPanel.legend.markers, ...
			gui.sParamTab.graphPanel.legend.text);
	end
	
	% Tooltip
	if gui.sParamTab.graphPanel.smith
		h = datacursormode(f);
		set(h, 'UpdateFcn', @dataTipSmith);
	end
	
	guidata(gui.window, gui);
	
end