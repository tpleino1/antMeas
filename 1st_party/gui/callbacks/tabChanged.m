function tabChanged( ~, eventData, gui, static )
% A callback that exist just to compensate some unidealities in the
% GUIToolBox. Run every time a tab is changed, even if done in the
% software.

	gui = guidata(gui.window);
	
	% Workaround to enable "Click to browse..." on inputTab
	if eventData.SelectedChild == 1
		a = strcat({'aut', 'aut', 'aut', 'ref', 'ref', 'ref'}, 'Panel');
		b = strcat({'horiz', 'vert', 'sParam', 'horiz', 'vert', 'eff'}, 'Edit');
		for i = 1 : length(a)
			set(gui.inputTab.(a{i}).(b{i}), ...
				'Enable', 	static.general.styles.edit.enable);
		end
	% Run defaults if needed
	elseif gui.dynamic.tabDefaults(eventData.SelectedChild)
		gui.dynamic.tabDefaults(eventData.SelectedChild) = false;
		switch (eventData.SelectedChild)
			case 2
				settingsDefault(gui.settingsTab.buttonRow.defaultsButton, [], gui, static);
			case 3
				scattDefaults(gui.sParamTab.settPanel.defaultsButton, [], gui, static);
			case 4
				pattDefaults(gui.pattTab.settPanel.defaultsButton, [], gui, static);
			case 5
				effDefaults(gui.effTab.settPanel.defaultsButton, [], gui, static);
		end
	% Workaround to ensure inactive totalEdit
	elseif eventData.SelectedChild == 2 && ...
			(gui.debug || gui.dynamic.enable.horiz || gui.dynamic.enable.vert)
		set(gui.settingsTab.interpPanel.totalEdit, 'Enable', static.general.styles.edit.enable);
	end
	
	guidata(gui.window, gui);

end

