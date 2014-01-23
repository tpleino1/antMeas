function scattChangeGraph(hObject, ~, gui)
% A callback to disable docked figures for dual-plots
	
	gui = guidata(gui.window);
	
	% GUI vs. cmd
	if ~isempty(hObject)
		gui.dynamic.sParam.graphType = ...
			get(gui.sParamTab.settPanel.graphSelect, 'Value');
	end
	
	% Dual-plot
	if (gui.dynamic.sParam.graphType > 4)
		set(gui.sParamTab.settPanel.replacementSelect, 'Value', 2);
		set(gui.sParamTab.settPanel.replacementSelect, 'Enable', 'off');
	% Re-enable
	elseif strcmpi(get(gui.sParamTab.settPanel.replacementSelect, 'Enable'), 'off')
		set(gui.sParamTab.settPanel.replacementSelect, 'Value', 1);
		set(gui.sParamTab.settPanel.replacementSelect, 'Enable', 'on');
	end
	
	guidata(gui.window, gui);
	
end