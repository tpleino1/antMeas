function pattPlot(hObject, ~, gui, static)
% A callback to plot the pattern	
		
	gui = guidata(gui.window);
	
	% Ignore GUI if ran from cmd
	if ~isempty(hObject)
		gui.dynamic.patt.replacement = ...
			get(gui.pattTab.settPanel.replacementSelect, 'Value');
		gui.dynamic.patt.overlay.selected = ...
			get(gui.pattTab.settPanel.overlayList, 'Value');
		gui.dynamic.patt.fixed.selected = ...
			get(gui.pattTab.settPanel.fixedSelect, 'Value');
		gui.dynamic.patt.polarization = ...
			get(gui.pattTab.settPanel.polarizationSelect, 'Value');
	end
	
	% Some shorthands
	fCoeff = static.tabs.settings.units.freq.coeffs(gui.dynamic.units.freq);
	fUnit = static.tabs.settings.units.freq.units{gui.dynamic.units.freq};
	pCoeff = static.tabs.settings.units.phase.coeffs(gui.dynamic.units.phase);
	pUnit = static.tabs.settings.units.phase.units{gui.dynamic.units.phase};
	
	misc = struct( ...
		'coeff',	struct( ...
			'freq',		fCoeff, ...
			'phase',	pCoeff, ...
			'prim',		pCoeff, ...
			'sec',		pCoeff ...
			), ....
		'unit',		struct( ...
			'freq',		fUnit, ...
			'phase',	pUnit, ...
			'prim',		pUnit, ...
			'sec',		pUnit ...
			), ...
		'label',	struct( ... % Axis labels
			'freq',		sprintf(static.tabs.patt.annotation.freq, fUnit), ...
			'phase',	sprintf(static.tabs.patt.annotation.phase, pUnit), ...
			'prim',		sprintf(static.tabs.patt.annotation.prim, pUnit), ...
			'sec',		sprintf(static.tabs.patt.annotation.sec, pUnit) ...
			), ...
		'fixed',	struct( ... % Title & Legend labels
			'freq',		sprintf(static.tabs.patt.annotation.markerFreq, fUnit), ...
			'phase',	sprintf(static.tabs.patt.annotation.markerPhase, pUnit), ...
			'prim',		sprintf(static.tabs.patt.annotation.markerPrim, pUnit), ...
			'sec',		sprintf(static.tabs.patt.annotation.markerSec, pUnit) ...
			) ...
		);

	% First, define x, y/overlay and z/fixed axes choices
	% Second, permute measurement data to match those choices
	
	fi = {'prim', 'sec', 'freq'};
	
	% x
	a = gui.dynamic.patt.firstAxis.selected;
	
	% y/overlay
	b = (1 : length(static.tabs.patt.plotSett.axis.options));
	b = b((1 : length(static.tabs.patt.plotSett.axis.options) ~= ...
					gui.dynamic.patt.firstAxis.selected));
	b = b(gui.dynamic.patt.secondAxis.selected);
	
	% z/fixed
	c = (1 : length(static.tabs.patt.plotSett.axis.options));
	c = c(c ~= a);
	c = c(c ~= b);
	
	% Aux struct where the axes and the related data 
	% are in the specified order 
	data = struct(...
		'x',	struct( ...
			'num',		a, ...
			'name',		fi{a}, ...
			'val',		gui.dynamic.interpolated.(fi{a}), ...
			'coeff',	misc.coeff.(fi{a}), ...
			'unit',		misc.unit.(fi{a}), ...
			'label',	misc.label.(fi{a}) ...
			), ...
		'y',	struct( ...
			'num',		b, ...
			'name',		fi{b}, ...
			'val',		gui.dynamic.interpolated.(fi{b}), ...
			'coeff',	misc.coeff.(fi{b}), ...
			'unit',		misc.unit.(fi{b}), ...
			'label',	misc.label.(fi{b}) ...
			), ...
		'z',	struct( ...
			'num',		c, ...
			'name',		fi{c}, ...
			'val',		gui.dynamic.interpolated.(fi{c}), ...
			'coeff',	misc.coeff.(fi{c}), ...
			'unit',		misc.unit.(fi{c}), ...
			'label',	misc.label.(fi{c}) ...
			), ...
		'v',		[], ...
		'maxAbs',	1 ...
		);
	
	% For 2D plots, use the whole range
	% For 1D plots, use the overlay values
	if gui.dynamic.patt.graphType < 3
		yIdx = gui.dynamic.patt.overlay.selected;
	else
		yIdx = 1 : length(data.y.val);
	end
	
	zIdx = gui.dynamic.patt.fixed.selected;
	
	% Polzarization selection/combination + Normalization
	switch (gui.dynamic.patt.polarization)
		case 1 % horiz
			h = permute(gui.dynamic.interpolated.aut.horiz, [a b c]);
			data.maxAbs = max(max(max(abs(h))));
			data.v = h(:, yIdx, zIdx);
			clear h;
		case 2 % vert
			v = permute(gui.dynamic.interpolated.aut.vert, [a b c]);
			data.maxAbs = max(max(max(abs(v))));
			data.v = v(:, yIdx, zIdx);
			clear v;
		case 3 % sum powers, avg phases
			h = permute(gui.dynamic.interpolated.aut.horiz, [a b c]);
			v = permute(gui.dynamic.interpolated.aut.vert, [a b c]);
			data.v = sqrt(abs(h).^2 + abs(v).^2) .* ...
				exp(1i * (angle(h) + angle(v)) / 2);
			data.maxAbs = max(max(max(abs(data.v))));
			data.v = data.v(:, yIdx, zIdx);
			clear h v;
		otherwise % sum fields
			h = permute(gui.dynamic.interpolated.aut.horiz, [a b c]);
			v = permute(gui.dynamic.interpolated.aut.vert, [a b c]);
			data.v = h + v;
			data.maxAbs = max(max(max(abs(data.v))));
			data.v = data.v(:, yIdx, zIdx);
			clear h v;
	end
	
	% 1D vs 2D plot?
	if (gui.dynamic.patt.graphType < 3)
		pattPlot1D(gui.dynamic.patt.graphType == 2);
	else
		pattPlot2D(gui.dynamic.patt.graphType == 4);
	end
	
	guidata(gui.window, gui);
	
	
	function pattPlot1D(p) 
	% v = v(x) for both rect and polar (p = true for latter)
		
		% Aux struct
		cfg = struct( ...
			'xGrid',	'on', ...
			'yGrid',	'on', ...
			'xLim',		[min(data.x.val) max(data.x.val)] / data.x.coeff, ...
			'yLim',		{[]}, ...
			'yStep',	{[]}, ...
			'yUnit',	{''}, ...
			'yLabel',	{''}, ...
			'xLabel',	data.x.label, ...
			'title',	sprintf(static.tabs.patt.annotation.polFixed, ...
							static.tabs.patt.plotSett.polarization.options{...
								gui.dynamic.patt.polarization}, ...
							sprintf(misc.fixed.(data.z.name), ...
								data.z.val(zIdx) / data.z.coeff)), ...
			'value',	{[]} ...
			);
							
		% Convert values
		switch (gui.dynamic.patt.value)
			case {1, 2}
				cfg.yLabel = {static.tabs.patt.annotation.linMag};
				cfg.value = {abs(data.v) / data.maxAbs};
				cfg.yLim = {static.plotting.polar.range.lin};
				cfg.yStep = {static.plotting.polar.step.lin};
				cfg.yUnit = {''};
			case 3
				cfg.yLabel = {misc.label.phase};
				cfg.value = {angle(data.v) / pi * 180 / pCoeff};
				cfg.yLim = {static.plotting.polar.range.phase / pCoeff};
				cfg.yStep = {static.plotting.polar.step.phase / pCoeff};
				cfg.yUnit = {pUnit};
			otherwise
				cfg.yLabel = {static.tabs.patt.annotation.linMag, misc.label.phase};
				cfg.value = {abs(data.v) / data.maxAbs, ...
					angle(data.v) / pi * 180 / pCoeff };
				cfg.yLim = { static.plotting.polar.range.lin, ...
					static.plotting.polar.range.phase / pCoeff };
				cfg.yStep = { static.plotting.polar.step.lin, ...
					static.plotting.polar.step.phase / pCoeff };
				cfg.yUnit = {'', pUnit};
		end
		
		% Extra for logaritmic magnitude
		if sum(gui.dynamic.patt.value == [2, 5]) > 0
			cfg.yLabel{1} = static.tabs.patt.annotation.logMag;
			cfg.yLim{1} = static.plotting.polar.range.log;
			cfg.yStep{1} = static.plotting.polar.step.log;
			cfg.yUnit{1} = 'dB';
			cfg.value{1} = 20 * log10(cfg.value{1});
		end
		
		% Prepare axes
		if gui.dynamic.patt.replacement == 1
			axesH = gui.pattTab.graphPanel.axes;
			gui.dynamic.patt.axesVisible = 'on';
			set(axesH, 'visible', 'on');
			cla(axesH, 'reset');
			set(gui.pattTab.settPanel.popButton, 'enable', 'on');
		else
			figH = figure('Name', static.plotting.figName.patt);
			gui.dynamic.plotting.figures(figH-1) = figH;
			if gui.dynamic.patt.value > 3
				z = 21 - 9 * (p && data.x.num == 1); % 21 or 12
				axesH = [subplot(10*z+1); subplot(10*z+2)];
				clear z;
			else
				axesH = axes('parent', figH);
			end
		end
		
		% Legend entries
		legH = zeros(size(axesH));
		entries = cell(size(cfg.value{1}, 2), 1);
		for i = 1 : length(entries)
			entries{i} = sprintf(misc.fixed.(data.y.name), ...
				data.y.val(yIdx(i)) / data.y.coeff);
		end
		
		% Plot
		lineH = zeros(length(axesH), length(entries));
		
		for i = 1 : length(axesH)
			% Polar plot -> init to polar
			if p
				initPolarPlot(axesH(i), ...
					'blocks',	static.plotting.polar.blocks, ...
					'range',	cfg.yLim{i}, ...
					'magUnit',	cfg.yUnit{i}, ...
					'step',		cfg.yStep{i}, ...
					'half',		data.x.num == 2, ...
					'ang',		gui.dynamic.units.phase ...
					);
			end
			
			set(axesH(i), 'nextPlot', 'add');
			% Plot each overlay value
			for j = 1 : length(entries)
				% Polar -> Normalize & plot with cos/sin
				if p
					v = min(1, max(0, ...
						(cfg.value{i}(:, j) - min(cfg.yLim{i})) / ...
							(max(cfg.yLim{i}) - min(cfg.yLim{i}))));
					x = data.x.val;
					if data.x.num == 2 && (min(x) < 0 || max(x) > 180)
						x = data.x.val + (90 - mean([min(x), max(x)]));
					end
					lineH(i, j) = plot(axesH(i), ...
						v .* cos(x / 180 * pi), ...
						v .* sin(x / 180 * pi));
					clear v x;
				else
					lineH(i, j) = plot(axesH(i), ...
						data.x.val / data.x.coeff, cfg.value{i}(:, j));
					%axis(axesH(i), 'auto');
					set(axesH(i), ...
						'xLim',			cfg.xLim, ...
						'xGrid',		cfg.xGrid, ...
						'yGrid',		cfg.yGrid ...
						);
				end
				
				% Style
				set(lineH(i, j), ...
					'lineWidth',	static.plotting.lineWidth, ...
					'lineStyle',	static.plotting.lineStyles{mod(j-1, 4) + 1}, ...
					'Color',		static.plotting.lineColors(mod(j-1, 11) + 1, :) ...
					);
			end
			set(axesH(i), 'nextPlot', 'replace');

			% Annotation
			set(get(axesH(i), 'xLabel'), 'String', cfg.xLabel);
			set(get(axesH(i), 'yLabel'), 'String', cfg.yLabel{i});
			set(get(axesH(i), 'title'), 'String', cfg.title);

			legH(i) = legend(axesH(i), lineH(i, :)', entries); % Legend
		end
		
		% Always at least one overlay -> Display legend
		if gui.dynamic.patt.replacement == 1
			gui.pattTab.graphPanel.legend.enable = true;
			gui.pattTab.graphPanel.legend.handles = legH;
			gui.pattTab.graphPanel.legend.markers = lineH;
			gui.pattTab.graphPanel.legend.text = entries;
		end
		
	end

	function pattPlot2D(s) 
	% v = v(x,y), used for both contourf and pcolor (s = true for latter)
		
	% Aux
		cfg = struct( ...
			'xGrid',	'on', ...
			'yGrid',	'on', ...
			'yLabel',	data.y.label, ...
			'xLabel',	data.x.label, ...
			'cLabel',	{''}, ...
			'title',	sprintf(misc.fixed.(data.z.name), ...
							data.z.val(zIdx) / data.z.coeff), ...
			'value',	{[]} ...
			);
							
		% Convert value
		switch (gui.dynamic.patt.value)
			case {1, 2}
				cfg.cLabel = {static.tabs.patt.annotation.linMag};
				cfg.value = {abs(data.v) / max(max(abs(data.v)))};
			case 3
				cfg.cLabel = {misc.label.phase};
				cfg.value = {angle(data.v) / pi * 180 / pCoeff};
			otherwise
				cfg.cLabel = {static.tabs.patt.annotation.linMag, misc.label.phase};
				cfg.value = {abs(data.v) / max(max(abs(data.v))), ...
					angle(data.v) / pi * 180 / pCoeff};
		end
		
		% Extra for logarithmic magnitude
		if sum(gui.dynamic.patt.value == [2, 5]) > 0
			cfg.cLabel{1} = static.tabs.patt.annotation.logMag;
			cfg.value{1} = 20 * log10(cfg.value{1});
		end
		
		% Prepare axes
		if gui.dynamic.patt.replacement == 1
			axesH = gui.pattTab.graphPanel.axes;
			gui.dynamic.patt.axesVisible = 'on';
			set(axesH, 'visible', 'on');
			cla(axesH, 'reset');
			set(gui.pattTab.settPanel.popButton, 'enable', 'on');
		else
			figH = figure('Name', static.plotting.figName.patt);
			gui.dynamic.plotting.figures(figH-1) = figH;
			if gui.dynamic.patt.value > 3
				axesH = [subplot(2, 1, 1); subplot(2, 1, 2)];
			else
				axesH = axes('parent', figH);
			end
		end
		
		% Plot
		for i = 1 : length(axesH)
			% surface / pcolor (always to new figure)
			if s
				pcolor(axesH(i), data.x.val / data.x.coeff, ...
					data.y.val / data.y.coeff, cfg.value{i}.');
				shading(axesH(i), static.plotting.surface.shading);
				caxis(axesH(i), 'auto');
				colormap(axesH(i), static.plotting.surface.colormap);
				colorbar('peer', axesH(i));
			% contourf
			else
				[C, h] = contourf(axesH(i), data.x.val / data.x.coeff, ...
					data.y.val / data.y.coeff, cfg.value{i}.');
				clabel(C, h, ...
					'labelSpacing', 	static.plotting.contour.labelSpacing, ...
					'fontWeight', 		static.plotting.contour.fontWeight, ...
					'color',			static.plotting.contour.color);
				colormap(axesH(i), static.plotting.contour.colormap);
				clear C h;
			end
			
			set(axesH(i), 'xGrid', cfg.xGrid, 'yGrid', cfg.yGrid);
			
			% Annotation
			set(get(axesH(i), 'xLabel'), 'String', cfg.xLabel);
			set(get(axesH(i), 'yLabel'), 'String', cfg.yLabel);
			set(get(axesH(i), 'title'), 'String', ...
				sprintf('%s (%s)', cfg.cLabel{i}, cfg.title));
		end
		
		% Never a legend, ever
		if gui.dynamic.patt.replacement == 1
			gui.pattTab.graphPanel.legend.enable = false;
			gui.pattTab.graphPanel.legend.handles = [];
			gui.pattTab.graphPanel.legend.markers = [];
			gui.pattTab.graphPanel.legend.text = {};
		end
		
	end
end