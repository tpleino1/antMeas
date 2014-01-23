function scattChangeMarker(~, ~, gui)
% A callback to ensure that none is not a part of a multiselection
	
	gui = guidata(gui.window);
	
	v = get(gui.sParamTab.settPanel.markerList, 'Value');
	
	% Remove 'None' if needed
	if (v(1) == 1 && numel(v) > 1)
		v = v(2 : end);
		set(gui.sParamTab.settPanel.markerList, 'Value', v);
	end
	
	gui.dynamic.sParam.markerFreq = v;
		
	guidata(gui.window, gui);
	
end