function scattPlot(hObject, ~, gui, static)
% A callback to plot the S-parameters
	
	gui = guidata(gui.window);
	
	% GUI vs. cmd
	if ~isempty(hObject)
		gui.dynamic.sParam.replacement = ...
			get(gui.sParamTab.settPanel.replacementSelect, 'Value');
		gui.dynamic.sParam.graphType = ...
			get(gui.sParamTab.settPanel.graphSelect, 'Value');
		gui.dynamic.sParam.freqRange = abs( ...
			[ str2double(get(gui.sParamTab.settPanel.freqMinEdit, 'String')), ...
			str2double(get(gui.sParamTab.settPanel.freqMaxEdit, 'String')) ] ...
			);
		gui.dynamic.sParam.markerFreq.options = ...
			get(gui.sParamTab.settPanel.markerList, 'String');
		gui.dynamic.sParam.markerFreq.selected = ...
			get(gui.sParamTab.settPanel.markerList, 'Value');
	end
	
	% Shorthands
	fCoeff = static.tabs.settings.units.freq.coeffs(gui.dynamic.units.freq);
	fUnit = static.tabs.settings.units.freq.units{gui.dynamic.units.freq};
	pCoeff = static.tabs.settings.units.phase.coeffs(gui.dynamic.units.phase);
	pUnit = static.tabs.settings.units.phase.units{gui.dynamic.units.phase};
	
	% Debugging vs. real values
	if gui.debug	
		temp = [	700000000,		-1.935354e-002,		-8.599066e-001; 
					740000000,		-2.074495e-001,		-7.327851e-001; 
					780000000,		-3.498306e-001,		-5.467571e-001; 
					820000000,		-3.904711e-001,		-2.414048e-001; 
					860000000,		-2.521909e-001,		1.760954e-002; 
					900000000,		-4.162773e-002,		1.517793e-001; 
					940000000,		1.431914e-001,		1.580457e-001; 
					980000000,		3.040194e-001,		1.229427e-001; 
					1020000000,		4.161218e-001,		5.819127e-002; 
					1060000000,		4.733624e-001,		-2.484506e-002;
					1100000000,		5.064241e-001,		-1.053195e-001		];
		f = temp(:, 1) / fCoeff;
		s = temp(:, 2) + 1i * temp(:, 3);
		clear temp;
	else
		f = gui.dynamic.original.aut.sParam.freq / fCoeff;
		s = gui.dynamic.original.aut.sParam.s11;
	end
	
	% Markers
	markerVal = gui.dynamic.sParam.markerFreq.selected;
	markerFreq = [];
	markerScatt = [];
	if ~isequal(markerVal, 1)
		markerStr = gui.dynamic.sParam.markerFreq.options(markerVal);

		markerFreq = zeros(length(markerVal), 1);
		markerScatt = zeros(size(markerFreq));
		format = ['%g ', fUnit];
		
		for i = 1 : length(markerVal)
			markerFreq(i) = sscanf(markerStr{i}, format, 1);
			markerScatt(i) = s(f == markerFreq(i));
		end
		
		clear format;
	end
	
	% Plot function based on graph type
	switch (gui.dynamic.sParam.graphType)
		case 1			% Smith
			scattPlotSmith();	
		case {2, 3, 4}	% Rectangle
			scattPlotRect();	
		otherwise		% Linear/logarithmic magnitude and phase
			scattPlotDual();
	end
	
	guidata(gui.window, gui);
	
	
	function scattPlotSmith()
	% Plot on a Smith Chart
		
		% Limit range
		idx = find(f >= min(gui.dynamic.sParam.freqRange) & ...
			f <= max(gui.dynamic.sParam.freqRange));
		s = s(idx);
		f = f(idx);
		clear idx;
		
		% Target axes
		if gui.dynamic.sParam.replacement == 1
			axesH = gui.sParamTab.graphPanel.axes;
			set(axesH, 'visible', 'on');
			cla(axesH, 'reset');
			set(gui.sParamTab.settPanel.popButton, 'enable', 'on');
		else
			figH = figure('Name', static.plotting.figName.sParam);
			gui.dynamic.plotting.figures(figH-1) = figH;
			axesH = axes('parent', figH);
		end
		
		% Create smithChart
		initSmithChart(axesH);
		set(axesH, 'nextPlot', 'add');
		
		% Plot curve
		plot(axesH, real(s), imag(s), ...
			'lineWidth',	static.plotting.lineWidth, ...
			'lineStyle',	static.plotting.lineStyles{1}, ...
			'Color',		static.plotting.lineColors(1, :) ...
			);
		
		% Add markers
		if ~isempty(markerFreq)
			
			markerH = zeros(length(markerFreq), 1);
			markerLegend = cell(length(markerFreq), 1);
			format = sprintf(static.tabs.sParam.annotation.markerFreq, fUnit);
			
			% Plot markers
			for j = 1 : length(markerFreq)
				markerH(j, 1) = plot(axesH, ...
					real(markerScatt(j)), imag(markerScatt(j)), ...
					'marker',				static.plotting.markers( ...
						mod(j-1, length(static.plotting.markers)) + 1), ...
					'lineStyle',			'None', ...
					'markerFaceColor',		static.plotting.lineColors(1, :), ...
					'markerEdgeColor',		0 * [1 1 1], ....
					'markerSize',			static.plotting.markerSize( ...
						mod(j-1, length(static.plotting.markerSize)) + 1) ...
					);
				markerLegend{j, 1} = sprintf(format, markerFreq(j));
			end
			clear format;
			
			% Set legend
			legH = legend(axesH, markerH, markerLegend);
			if gui.dynamic.sParam.replacement == 1
				gui.sParamTab.graphPanel.smith = true;
				gui.sParamTab.graphPanel.legend.enable = true;
				gui.sParamTab.graphPanel.legend.handles = legH;
				gui.sParamTab.graphPanel.legend.markers = markerH;
				gui.sParamTab.graphPanel.legend.text = markerLegend;
			end
		% Remove previous legend from docked
		elseif gui.dynamic.sParam.replacement == 1
			legend(axesH, 'off');
			gui.sParamTab.graphPanel.smith = true;
			gui.sParamTab.graphPanel.legend.enable = false;
			gui.sParamTab.graphPanel.legend.handles = [];
			gui.sParamTab.graphPanel.legend.markers = [];
			gui.sParamTab.graphPanel.legend.text = {};
		end
		set(axesH, 'nextPlot', 'replace');
		
		% Add DataTips to new figure
		if gui.dynamic.sParam.replacement ~= 1
			hh = datacursormode(figH);
			set(hh, 'UpdateFcn', @dataTipSmith);
		end
		
	end


	function scattPlotRect()
	% Plot using rectangular coordinates
		
		% Aux/helper 
		cfg = struct( ...
			'xGrid',	'on', ...
			'yGrid',	'on', ...
			'xLim',		gui.dynamic.sParam.freqRange, ...
			'xLabel',	sprintf(static.tabs.sParam.annotation.freq, fUnit) ...
			);
							
		% Plot value
		switch (gui.dynamic.sParam.graphType)
			case 2
				cfg.yLabel = static.tabs.sParam.annotation.linMag;
				cfg.value = abs(s);
				cfg.markerPlotVal = abs(markerScatt);
				cfg.markerLegendVal = angle(s) / pi * 180 / pCoeff;
				cfg.markerLegendFormat = sprintf(static.tabs.sParam.annotation.markerPhase, pUnit);
			case 3
				cfg.yLabel = static.tabs.sParam.annotation.logMag;
				cfg.value = 20 * log10(abs(s));
				cfg.markerPlotVal = 20 * log10(abs(markerScatt));
				cfg.markerLegendVal = angle(markerScatt) / pi * 180 / pCoeff;
				cfg.markerLegendFormat = sprintf(static.tabs.sParam.annotation.markerPhase, pUnit);
			otherwise
				cfg.yLabel = sprintf(static.tabs.sParam.annotation.phase, pUnit);
				cfg.value = angle(s) / pi * 180 / pCoeff;
				cfg.markerPlotVal = angle(markerScatt) / pi * 180 / pCoeff;
				cfg.markerLegendVal = 20 * log10(abs(markerScatt));
				cfg.markerLegendFormat = static.tabs.sParam.annotation.markerLogMag;
		end
		
		% Target axes
		if gui.dynamic.sParam.replacement == 1
			axesH = gui.sParamTab.graphPanel.axes;
			gui.dynamic.eff.axesVisible = 'on';
			set(axesH, 'visible', 'on');
			cla(axesH);
			set(gui.sParamTab.settPanel.popButton, 'enable', 'on');
			cfg.title = '';
		else
			figH = figure('Name', static.plotting.figName.sParam);
			gui.dynamic.plotting.figures(figH-1) = figH;
			axesH = axes('parent', figH);
			cfg.title = static.plotting.figName.sParam;
		end
		
		% Plot & fine-tune axes
		plot(axesH, f, cfg.value, ...
			'lineWidth',	static.plotting.lineWidth, ...
			'lineStyle',	static.plotting.lineStyles{1}, ...
			'Color',		static.plotting.lineColors(1, :) ...
			);
		set(axesH, ...
			'xGrid',		cfg.xGrid, ...
			'yGrid',		cfg.yGrid, ...
			'xLim',			cfg.xLim ...
			);
		set(get(axesH, 'xLabel'), 'String', cfg.xLabel);
		set(get(axesH, 'yLabel'), 'String', cfg.yLabel);
		set(get(axesH, 'title'), 'String', cfg.title);
		
		% Markers
		if ~isempty(markerFreq)
			markerH = zeros(length(markerFreq), 1);
			markerLegend = cell(length(markerFreq), 1);

			% Plot
			set(axesH, 'NextPlot', 'add');
			for j = 1 : length(markerFreq)
				markerH(j, 1) = plot(axesH, markerFreq(j), cfg.markerPlotVal(j), ...
					'marker',				static.plotting.markers( ...
						mod(j-1, length(static.plotting.markers)) + 1), ...
					'lineStyle',			'None', ...
					'markerFaceColor',		static.plotting.lineColors(1, :), ...
					'markerEdgeColor',		0 * [1 1 1], ....
					'markerSize',			static.plotting.markerSize( ...
						mod(j-1, length(static.plotting.markerSize)) + 1) ...
					);
				markerLegend{j, 1} = sprintf(cfg.markerLegendFormat, ...
					cfg.markerLegendVal(j));
			end
			set(axesH, 'NextPlot', 'replace');

			% Legend
			legH = legend(axesH, markerH, markerLegend);
			if gui.dynamic.sParam.replacement == 1
				gui.sParamTab.graphPabel.smith = false;
				gui.sParamTab.graphPanel.legend.enable = true;
				gui.sParamTab.graphPanel.legend.handles = legH;
				gui.sParamTab.graphPanel.legend.markers = markerH;
				gui.sParamTab.graphPanel.legend.text = markerLegend;
			end
		% Remove previous legend
		elseif gui.dynamic.sParam.replacement == 1
			legend(axesH, 'off');
			gui.sParamTab.graphPabel.smith = false;
			gui.sParamTab.graphPanel.legend.enable = false;
			gui.sParamTab.graphPanel.legend.handles = [];
			gui.sParamTab.graphPanel.legend.markers = [];
			gui.sParamTab.graphPanel.legend.text = {};
		end
	end


	function scattPlotDual()
	% Dual-plot using rectangular coordinates
	
		% Aux / helper
		cfg = struct( ...
			'xGrid',				'on', ...
			'yGrid',				'on', ...
			'xLim',					gui.dynamic.sParam.freqRange, ...
			'xLabel',				sprintf(static.tabs.sParam.annotation.freq, fUnit), ...
			'left',					struct( ...
				'yLabel',				'', ...
				'value',				[], ...
				'markerPlotVal',		[] ...
				), ...
			'right',				struct( ...
				'yLabel',				sprintf(static.tabs.sParam.annotation.phase, pUnit), ...
				'value',				angle(s) / pi * 180 / pCoeff, ...
				'markerPlotVal',		angle(markerScatt) / pi * 180 / pCoeff ...
				), ...
			'markerLegendVal',		[], ...
			'markerLegendFormat',	'' ...
			);
					
		% Plot value
		if gui.dynamic.sParam.graphType == 5	% Linear magnitude
			cfg.left.yLabel = static.tabs.sParam.annotation.linMag;
			cfg.left.value = abs(s);
			cfg.left.markerPlotVal = abs(markerScatt);
			cfg.markerLegendVal = 20 * log10(markerScatt);
			cfg.markerLegendFormat = static.tabs.sParam.annotation.markerLogMag;
		else	% Logarithmic magnitude
			cfg.left.yLabel = static.tabs.sParam.annotation.logMag;
			cfg.left.value = 20 * log10(abs(s));
			cfg.left.markerPlotVal = 20 * log10(abs(markerScatt));
			cfg.markerLegendVal = abs(markerScatt);
			cfg.markerLegendFormat = static.tabs.sParam.annotation.markerLinMag;
		end
		
		figH = figure('Name', static.plotting.figName.sParam);
		gui.dynamic.plotting.figures(figH-1) = figH;
		
		% Plot & fine-tune axes
		[ax, lh1, lh2] = plotyy(f, cfg.left.value, f, cfg.right.value);
		set(ax(1), ...
			'xGrid',		cfg.xGrid, ...
			'yGrid',		cfg.yGrid, ...
			'xLim',			cfg.xLim, ...
			'YColor',		0 * [1 1 1] ...
			);
		set(ax(2), ...
			'xGrid',		'off', ...
			'yGrid',		'off', ...
			'xLim',			cfg.xLim, ...
			'YColor',		0 * [1 1 1] ...
			);
		set(get(ax(1), 'Ylabel'), ...
			'String',		cfg.left.yLabel, ...
			'Color',		static.plotting.lineColors(1, :)...
			); 
		set(get(ax(2), 'Ylabel'), ...
			'String',		cfg.right.yLabel, ...
			'Color',		static.plotting.lineColors(2, :)...
			);
		set(lh1, ...
			'LineStyle',	static.plotting.lineStyles{1}, ...
			'lineWidth',	static.plotting.lineWidth, ...
			'color',		static.plotting.lineColors(1, :)...
			);
		set(lh2, ...
			'LineStyle',	static.plotting.lineStyles{1}, ...
			'lineWidth',	static.plotting.lineWidth, ...
			'color',		static.plotting.lineColors(2, :)...
			);
		xlabel(cfg.xLabel);
		title(static.plotting.figName.sParam);
		
		% Markers
		if ~isempty(markerFreq)
			markerH = zeros(length(markerFreq), 1);
			markerLegend = cell(length(markerFreq), 1);

			% Plot
			set(ax, 'NextPlot', 'add');
			for j = 1 : length(markerFreq)
				markerH(j, 1) = plot(ax(1), markerFreq(j), cfg.left.markerPlotVal(j), ...
					'marker',				static.plotting.markers( ...
						mod(j-1, length(static.plotting.markers)) + 1), ...
					'lineStyle',			'None', ...
					'markerFaceColor',		static.plotting.lineColors(1, :), ...
					'markerEdgeColor',		0 * [1 1 1], ....
					'markerSize',			static.plotting.markerSize( ...
						mod(j-1, length(static.plotting.markerSize)) + 1) ...
					);
				plot(ax(2), markerFreq(j), cfg.right.markerPlotVal(j), ...
					'marker',				static.plotting.markers( ...
						mod(j-1, length(static.plotting.markers)) + 1), ...
					'lineStyle',			'None', ...
					'markerFaceColor',		static.plotting.lineColors(2, :), ...
					'markerEdgeColor',		0 * [1 1 1], ....
					'markerSize',			static.plotting.markerSize( ...
						mod(j-1, length(static.plotting.markerSize)) + 1) ...
					);
				markerLegend{j, 1} = sprintf(cfg.markerLegendFormat, ...
					cfg.markerLegendVal(j));
			end
			set(ax, 'NextPlot', 'replace');

			% Legend
			legend(ax(1), markerH, markerLegend);
		end
		
	end
	
end