function createPattTab(gui, static)
% Fills the pattern tab.

	gui = guidata(gui.window);
	
	% Local config (for overriding)
 	cfg = struct( ...
			... % Styles
		'padding',					static.general.styles.hBox.padding, ...
		'spacing',					static.general.styles.hBox.spacing, ...
		'panelBorderType',			static.general.styles.panel.borderType, ...
		'panelHighlightColor',		static.general.styles.panel.highlightColor, ...
		'panelBorderWidth',			static.general.styles.panel.borderWidth, ...
		'selectBackgroundColor',	static.general.styles.select.backgroundColor, ...
		'listBackgroundColor',		static.general.styles.list.backgroundColor, ...
		'labelAlign',				static.general.styles.label.textAlign{1}, ...
			... % Geometry
		'buttonWidth',				static.general.geometry.button(2), ...
		'labelWidth',				static.general.geometry.label(3), ...
		'rowHeight',				static.general.geometry.row, ...
			... % Sizes
		'sizes',					[] ...
		);

	cfg.sizes = struct( ...
		'leftHBox',				[cfg.labelWidth -1], ...
		'leftVBox',				cfg.rowHeight(2) * ones(1, 7), ...
		'rightVBox',			[cfg.rowHeight(1) -1], ...
		'topHBox',				[-5 -3], ...
		'buttonHBox',			max(-1, cfg.buttonWidth * [1 -1 1 1]), ...
		'settPanel',			[220 cfg.rowHeight(3)], ...
		'pattLayout',			[260 -1] ...
		);

	% Plot settings
	gui.pattTab.settPanel = struct('panel', uiextras.Panel(...
		'Parent',				gui.pattTab.pattLayout, ...
		'BorderType',			cfg.panelBorderType, ...
		'HighlightColor',		cfg.panelHighlightColor, ...
		'BorderWidth',			cfg.panelBorderWidth, ...
		'Title',				[' ', static.tabs.patt.settPanel.title, '  '] ...
		));

	% VBox for top_ and button_
	% HBox for left and right
	% VBox for each individual row on the left
	gui.pattTab.settPanel.vBox = uiextras.VBox(...
		'Parent',				gui.pattTab.settPanel.panel ...
		);

	gui.pattTab.settPanel.topHBox = uiextras.HBox(...
		'Parent',				gui.pattTab.settPanel.vBox ...
		);

	gui.pattTab.settPanel.leftVBox = uiextras.VBox(...
		'Parent',				gui.pattTab.settPanel.topHBox ...
		);

	% Graph Type
	gui.pattTab.settPanel.graphHBox = uiextras.HBox( ...
		'Parent',				gui.pattTab.settPanel.leftVBox, ...
		'Spacing',				cfg.spacing, ...
		'Padding',				cfg.padding ...
		);

	gui.pattTab.settPanel.graphLabel = uicontrol(...
		'Style',				'Text', ...
		'Parent',				gui.pattTab.settPanel.graphHBox, ...
		'HorizontalAlignment',	cfg.labelAlign, ...
		'String',				static.tabs.patt.settPanel.graphLabel ...
		);

	gui.pattTab.settPanel.graphSelect = uicontrol(...
		'Style',				'Popupmenu', ...
		'Parent',				gui.pattTab.settPanel.graphHBox, ...
		'String',				static.tabs.patt.plotSett.graphType.options, ...
		'Value',				static.tabs.patt.plotSett.graphType.default, ...
		'Callback', 			{@pattChangeGraph, gui, static, 1}, ...
		'BackgroundColor',		cfg.selectBackgroundColor ...
		); 

	set(gui.pattTab.settPanel.graphHBox, 'Sizes', cfg.sizes.leftHBox);

	% First Axis
	gui.pattTab.settPanel.firstAxisHBox = uiextras.HBox( ...
		'Parent',				gui.pattTab.settPanel.leftVBox, ...
		'Spacing',				cfg.spacing, ...
		'Padding',				cfg.padding ...
		);

	gui.pattTab.settPanel.firstAxisLabel = uicontrol(...
		'Style',				'Text', ...
		'Parent',				gui.pattTab.settPanel.firstAxisHBox, ...
		'HorizontalAlignment',	cfg.labelAlign, ...
		'String',				static.tabs.patt.settPanel.firstLabel ...
		);

	gui.pattTab.settPanel.firstAxisSelect = uicontrol(...
		'Style',				'Popupmenu', ...
		'Parent',				gui.pattTab.settPanel.firstAxisHBox, ...
		'String',				static.tabs.patt.plotSett.axis.options, ...
		'Value',				static.tabs.patt.plotSett.axis.default, ...
		'Callback', 			{@pattChangeGraph, gui, static, 2}, ...
		'BackgroundColor',		cfg.selectBackgroundColor ...
		); 

	set(gui.pattTab.settPanel.firstAxisHBox, 'Sizes', cfg.sizes.leftHBox);

	% Second Axis / Overlay
	gui.pattTab.settPanel.secondAxisHBox = uiextras.HBox( ...
		'Parent',				gui.pattTab.settPanel.leftVBox, ...
		'Spacing',				cfg.spacing, ...
		'Padding',				cfg.padding ...
		);

	gui.pattTab.settPanel.secondAxisLabel = uicontrol(...
		'Style',				'Text', ...
		'Parent',				gui.pattTab.settPanel.secondAxisHBox, ...
		'HorizontalAlignment',	cfg.labelAlign, ...
		'String',				static.tabs.patt.settPanel.secondLabel.options{ ...
									static.tabs.patt.settPanel.secondLabel.default} ...
		);

	gui.pattTab.settPanel.secondAxisSelect = uicontrol(...
		'Style',				'Popupmenu', ...
		'Parent',				gui.pattTab.settPanel.secondAxisHBox, ...
		'String',				gui.dynamic.patt.secondAxis.options, ...
		'Value',				gui.dynamic.patt.secondAxis.selected, ...
		'Callback', 			{@pattChangeGraph, gui, static, 3}, ...
		'BackgroundColor',		cfg.selectBackgroundColor ...
		); 

	set(gui.pattTab.settPanel.secondAxisHBox, 'Sizes', cfg.sizes.leftHBox);

	% Fixed variable
	gui.pattTab.settPanel.fixedHBox = uiextras.HBox( ...
		'Parent',				gui.pattTab.settPanel.leftVBox, ...
		'Spacing',				cfg.spacing, ...
		'Padding',				cfg.padding ...
		);

	gui.pattTab.settPanel.fixedLabel = uicontrol(...
		'Style',				'Text', ...
		'Parent',				gui.pattTab.settPanel.fixedHBox, ...
		'HorizontalAlignment',	cfg.labelAlign, ...
		'String',				sprintf(static.tabs.patt.settPanel.fixedLabel, ...
									lower(gui.dynamic.patt.fixed.variable)) ...
		);

	gui.pattTab.settPanel.fixedSelect = uicontrol(...
		'Style',				'Popupmenu', ...
		'Parent',				gui.pattTab.settPanel.fixedHBox, ...
		'String',				{static.tabs.patt.settPanel.noneText}, ...
		'Value',				1, ...
		'BackgroundColor',		cfg.selectBackgroundColor ...
		); 

	set(gui.pattTab.settPanel.fixedHBox, 'Sizes', cfg.sizes.leftHBox);
	
	% Polarization
	gui.pattTab.settPanel.polarizationHBox = uiextras.HBox( ...
		'Parent',				gui.pattTab.settPanel.leftVBox, ...
		'Spacing',				cfg.spacing, ...
		'Padding',				cfg.padding ...
		);

	gui.pattTab.settPanel.polarizationLabel = uicontrol(...
		'Style',				'Text', ...
		'Parent',				gui.pattTab.settPanel.polarizationHBox, ...
		'HorizontalAlignment',	cfg.labelAlign, ...
		'String',				static.tabs.patt.settPanel.polLabel ...
		);

	gui.pattTab.settPanel.polarizationSelect = uicontrol(...
		'Style',				'Popupmenu', ...
		'Parent',				gui.pattTab.settPanel.polarizationHBox, ...
		'String',				static.tabs.patt.plotSett.polarization.options, ...
		'Value',				static.tabs.patt.plotSett.polarization.default, ...
		'BackgroundColor',		cfg.selectBackgroundColor ...
		); 

	set(gui.pattTab.settPanel.polarizationHBox, 'Sizes', cfg.sizes.leftHBox);

	% Plot value
	gui.pattTab.settPanel.valueHBox = uiextras.HBox( ...
		'Parent',				gui.pattTab.settPanel.leftVBox, ...
		'Spacing',				cfg.spacing, ...
		'Padding',				cfg.padding ...
		);

	gui.pattTab.settPanel.valueLabel = uicontrol(...
		'Style',				'Text', ...
		'Parent',				gui.pattTab.settPanel.valueHBox, ...
		'HorizontalAlignment',	cfg.labelAlign, ...
		'String',				static.tabs.patt.settPanel.plotValLabel ...
		);

	gui.pattTab.settPanel.valueSelect = uicontrol(...
		'Style',				'Popupmenu', ...
		'Parent',				gui.pattTab.settPanel.valueHBox, ...
		'String',				static.tabs.patt.plotSett.value.options, ...
		'Value',				static.tabs.patt.plotSett.value.default, ...
		'Callback', 			{@pattChangeGraph, gui, static, 4}, ...
		'BackgroundColor',		cfg.selectBackgroundColor ...
		); 

	set(gui.pattTab.settPanel.valueHBox, 'Sizes', cfg.sizes.leftHBox);

	% Replacement
	gui.pattTab.settPanel.replacementHBox = uiextras.HBox( ...
		'Parent',				gui.pattTab.settPanel.leftVBox, ...
		'Spacing',				cfg.spacing, ...
		'Padding',				cfg.padding ...
		);

	gui.pattTab.settPanel.replacementLabel = uicontrol(...
		'Style',				'Text', ...
		'Parent',				gui.pattTab.settPanel.replacementHBox, ...
		'HorizontalAlignment', 	cfg.labelAlign, ...
		'String',				static.tabs.patt.settPanel.replLabel ...
		);

	gui.pattTab.settPanel.replacementSelect = uicontrol(...
		'Style',				'Popupmenu', ...
		'Parent',				gui.pattTab.settPanel.replacementHBox, ...
		'String',				static.tabs.patt.plotSett.replacement.options, ...
		'Value',				static.tabs.patt.plotSett.replacement.default, ...
		'BackgroundColor',		cfg.selectBackgroundColor ...
		); 

	set(gui.pattTab.settPanel.replacementHBox, 'Sizes', cfg.sizes.leftHBox);

	set(gui.pattTab.settPanel.leftVBox, 'Sizes', cfg.sizes.leftVBox);

	% Overlay-list
	gui.pattTab.settPanel.rightVBox = uiextras.VBox( ...
		'Parent',				gui.pattTab.settPanel.topHBox, ...
		'Spacing',				cfg.spacing, ...
		'Padding',				cfg.padding ...
		);

	gui.pattTab.settPanel.overlayLabel = uicontrol(...
		'Style',				'Text', ...
		'Parent',				gui.pattTab.settPanel.rightVBox, ...
		'HorizontalAlignment',	cfg.labelAlign, ...
		'String',				static.tabs.patt.settPanel.overlayLabel ...
		);

	gui.pattTab.settPanel.overlayList = uicontrol(...
		'Style',				'ListBox', ...
		'Parent',				gui.pattTab.settPanel.rightVBox, ...
		'String',				{static.tabs.patt.settPanel.noneText}, ...
		'Value',				1, ...
		'Min',					1, ...
		'Max',					1, ...
		'BackgroundColor',		cfg.listBackgroundColor ...
		); 

	set(gui.pattTab.settPanel.rightVBox, 'Sizes', cfg.sizes.rightVBox);

	set(gui.pattTab.settPanel.topHBox, 'Sizes', cfg.sizes.topHBox);

	% Buttons
	gui.pattTab.settPanel.buttonHBox = uiextras.HBox( ...
		'Parent',				gui.pattTab.settPanel.vBox, ...
		'Spacing',				cfg.spacing, ...
		'Padding',				cfg.padding ...
		);

	gui.pattTab.settPanel.popButton = uicontrol(...
		'Style',				'PushButton', ...
		'Parent',				gui.pattTab.settPanel.buttonHBox, ...
		'String',				static.tabs.patt.settPanel.popButt, ...
		'Callback',				{@pattPop, gui, static}, ...
		'Enable',				'Off' ...
		);

	gui.pattTab.settPanel.spacer = uiextras.Empty( ...
		'Parent',				gui.pattTab.settPanel.buttonHBox);

	gui.pattTab.settPanel.defaultsButton = uicontrol(...
		'Style',				'PushButton', ...
		'Parent',				gui.pattTab.settPanel.buttonHBox, ...
		'String',				static.tabs.patt.settPanel.defButt, ...
		'Callback',				{@pattDefaults, gui, static} ...
		);

	gui.pattTab.settPanel.plotButton = uicontrol(...
		'Style',				'PushButton', ...
		'Parent',				gui.pattTab.settPanel.buttonHBox, ...
		'String',				static.tabs.patt.settPanel.plotButt, ...
		'Callback',				{@pattPlot, gui, static} ...
		);

	set(gui.pattTab.settPanel.buttonHBox, 'Sizes', cfg.sizes.buttonHBox);

	set(gui.pattTab.settPanel.vBox, 'Sizes', cfg.sizes.settPanel);

	% Graph
	gui.pattTab.graphPanel = struct('panel', uiextras.Panel(...
		'Parent',				gui.pattTab.pattLayout, ...
		'BorderType',			cfg.panelBorderType, ...
		'HighlightColor',		cfg.panelHighlightColor, ...
		'BorderWidth',			cfg.panelBorderWidth, ...
		'Padding',				cfg.padding, ...
		'Title',				[' ', static.tabs.patt.graphPanel.title, '  '] ...
		));

	gui.pattTab.graphPanel.axes = axes( ...
		'Parent',					gui.pattTab.graphPanel.panel, ...
		'ActivePositionProperty',	'OuterPosition', ...
		'Visible',					'Off' ...
		);
	
	gui.pattTab.graphPanel.legend = struct( ...
		'enable',	false, ...
		'handles',	[], ...
		'markers',	[], ...
		'text',		{{}} ...
		);

	set(gui.pattTab.pattLayout, 'Sizes', cfg.sizes.pattLayout);
	
	guidata(gui.window, gui);

end
