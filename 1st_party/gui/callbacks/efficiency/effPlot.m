function effPlot(hObject, ~, gui, static)
% A callback to plot the efficiency as a function of frequency
	
	gui = guidata(gui.window);
	
	% Ignore GUI if ran from cmd
	if ~isempty(hObject)
		gui.dynamic.eff.replacement = ...
			get(gui.effTab.settPanel.replacementSelect, 'Value');
		gui.dynamic.eff.unit = get(gui.effTab.settPanel.unitSelect, 'Value');
	end
	
	% Calculate only once
	if ~gui.dynamic.eff.data.calc

		% Shorthands
		f = gui.dynamic.interpolated.freq;
		t = antEfficiency(gui.dynamic.interpolated);
		s = abs(gui.dynamic.interpolated.aut.sParam);
		
		% Debug values
		if gui.debug && (isempty(f) || isempty(t) || isempty(s))
			temp = [ 	700.00 		19.774142 	-1.308775;
						740.00 		35.279219 	-2.365650;
						780.00		52.080770	-3.753830;
						820.00		74.190068	-6.762449;
						860.00 		91.736786 	-11.944288;
						900.00 		95.952897 	-16.060771;
						940.00 		94.411354 	-13.421583;
						980.00 		87.817798 	-9.684191;
						1020.00 	80.369347 	-7.531481;
						1060.00 	75.050082 	-6.484177;
						1100.00 	70.314474 	-5.725828	]; 
			f = temp(:, 1) * 1e6;
			t = temp(:, 2) / 100;
			s = 10 .^ (temp(:, 3) / 20);
			clear temp;
		end
		
		m = 1 - s .^ 2;
		
		gui.dynamic.eff.data.freq = f;
		gui.dynamic.eff.data.total = t;
		gui.dynamic.eff.data.s11 = s;
		gui.dynamic.eff.data.matching = m;
		gui.dynamic.eff.data.radiation = t ./ m;
		gui.dynamic.eff.data.calc = true;
		
		clear f t s m;
	end
	
	% Auxiliary shorthands
	fCoeff = static.tabs.settings.units.freq.coeffs(gui.dynamic.units.freq);
	fUnit = static.tabs.settings.units.freq.units{gui.dynamic.units.freq};

	cfg = struct( ...
		'xGrid',	'on', ...
		'yGrid',	'on', ...
		'freq',		gui.dynamic.eff.data.freq / fCoeff, ...
		'xLim',		[], ...
		'xLabel',	sprintf(static.tabs.eff.annotation.freq, fUnit), ...
		'values',	struct( ...
			'total',		[], ...
			'radiation',	[], ...
			'matching',		[] ...
			) ...
		);
	
	cfg.xLim = [min(cfg.freq) max(cfg.freq)];

	% Convert value
	switch gui.dynamic.eff.unit
		
		case 3		% dB
			cfg.yLabel = static.tabs.eff.annotation.decibels;
			cfg.values.total = 10 * log10(gui.dynamic.eff.data.total);
			cfg.values.matching = 10 * log10(gui.dynamic.eff.data.matching);
			cfg.values.radiation = 10 * log10(gui.dynamic.eff.data.radiation);
		case 2		% 0...1
			cfg.yLabel = static.tabs.eff.annotation.decimal;
			cfg.values.total = gui.dynamic.eff.data.total;
			cfg.values.matching = gui.dynamic.eff.data.matching;
			cfg.values.radiation = gui.dynamic.eff.data.radiation;
		otherwise 	% percent
			cfg.yLabel = static.tabs.eff.annotation.percent;
			cfg.values.total = 100 * gui.dynamic.eff.data.total;
			cfg.values.matching = 100 * gui.dynamic.eff.data.matching;
			cfg.values.radiation = 100 * gui.dynamic.eff.data.radiation;
		
	end

	% Init axes
	if gui.dynamic.eff.replacement == 1
		%figH = gui.window;
		axesH = gui.effTab.graphPanel.axes;
		gui.dynamic.eff.axesVisible = 'on';
		set(axesH, 'visible', 'on');
		cla(axesH, 'reset');
		cfg.title = '';
		set(gui.effTab.settPanel.popButton, 'enable', 'on');
	else
		figH = figure('Name', static.plotting.figName.eff);
		gui.dynamic.plotting.figures(figH-1) = figH;
		axesH = axes('parent', figH);
		cfg.title = static.plotting.figName.eff;
	end

	% Plot: Total, Radiation & Matching efficiencies
	markerH = zeros(3, 1);

	markerH(1) = plot(axesH, cfg.freq, cfg.values.total, ...
		'lineWidth',	static.plotting.lineWidth, ...
		'lineStyle',	static.plotting.lineStyles{1}, ...
		'Color',		static.plotting.lineColors(1, :) ...
		);

	set(axesH, 'NextPlot', 'add');

	markerH(2) = plot(axesH, cfg.freq, cfg.values.radiation, ...
		'lineWidth',	static.plotting.lineWidth, ...
		'lineStyle',	static.plotting.lineStyles{2}, ...
		'Color',		static.plotting.lineColors(2, :) ...
		);

	markerH(3) = plot(axesH, cfg.freq, cfg.values.matching, ...
		'lineWidth',	static.plotting.lineWidth, ...
		'lineStyle',	static.plotting.lineStyles{3}, ...
		'Color',		static.plotting.lineColors(3, :) ...
		);
	
	% "Finishing up"
	set(axesH, 'NextPlot', 'replace');

	set(axesH, ...
		'xGrid',		cfg.xGrid, ...
		'yGrid',		cfg.yGrid, ...
		'xLim',			cfg.xLim ...
		);

	set(get(axesH, 'xLabel'), 'String', cfg.xLabel);
	set(get(axesH, 'yLabel'), 'String', cfg.yLabel);
	set(get(axesH, 'title'), 'String', cfg.title);
		
	% Set legend always
	markerLegend = { static.tabs.eff.annotation.total, ...
		static.tabs.eff.annotation.radiation, ...
		static.tabs.eff.annotation.matching };
	legH = legend(axesH, markerH, markerLegend);
	
	if gui.dynamic.eff.replacement == 1
		gui.effTab.graphPanel.legend.enable = true;
		gui.effTab.graphPanel.legend.handles = legH;
		gui.effTab.graphPanel.legend.markers = markerH;
		gui.effTab.graphPanel.legend.text = markerLegend;
	end

	guidata(gui.window, gui);
		
end