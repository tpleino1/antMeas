function [d] = initDynamic(s)
% Initializes data structure containing dynamic data

	d = struct( ...
		'enable',	struct( ...
			'sParam',	false, ... % aut
			'horiz',	false, ... % aut
			'vert',		false, ... % aut
			'eff',		false ...  % aut & ref
			), ...
		'tabDefaults',	 [0 1 1 1 1], ...
		'interpolated',		struct( ...
			'calc',		false, ...
			'aut',		struct( ...
				'horiz', 	[], ...
				'vert',		[], ...
				'sParam',	[] ...
				), ...
			'ref',		struct( ...
				'horiz',	[], ...
				'vert',		[], ...
				'eff',		[] ...
				), ...
			'freq',			[], ...
			'prim',			[], ...
			'sec',			[] ...
			), ...
		'original',		 struct( ...
			'aut',			struct( ...
				'sParam',		struct( ...
					'freq',			[], ...
					's11',			[], ...
					'z0',			[] ...
					), ...
				'horiz',		struct( ...
					'freq',			[], ...
					'prim',			[], ...
					'sec',			[], ...
					'data',			[] ...
					), ...
				'vert',			struct( ...
					'freq',			[], ...
					'prim',			[], ...
					'sec',			[], ...
					'data',			[] ...
					) ...
				), ...
			'ref',			struct( ...
				'eff',			struct( ...
					'freq',			[], ...
					'eff',			[], ...
					's11',			[] ...
					), ...
				'horiz',		struct( ...
					'freq',			[], ...
					'prim',			[], ...
					'sec',			[], ...
					'data',			[] ...
					), ...
				'vert',			struct( ...
					'freq',			[], ...
					'prim',			[], ...
					'sec',			[], ...
					'data',			[] ...
					) ...
				),...
			'freq',			[], ...
			'prim',			[], ...
			'sec',			[] ...
			), ...
		'io',		struct( ...
			'export',	struct( ...
				'file',		'', ...
				'path',		'', ...
				'index',	0 ...
				), ...
			'aut',		struct( ...
				'horiz',	struct( ...
					'file',		'', ...
					'path',		'', ...
					'index',	0 ...
					), ...
				'vert',		struct( ...
					'file',		'', ...
					'path',		'', ...
					'index',	0 ...
					), ...
				'sParam',	struct( ...
					'file',		'', ...
					'path',		'', ...
					'index',	0 ...
					) ...
				), ...
			'ref',		struct( ...
				'horiz',	struct( ...
					'file',		'', ...
					'path',		'', ...
					'index',	0 ...
					), ...
				'vert',		struct( ...
					'file',		'', ...
					'path',		'', ...
					'index',	0 ...
					), ...
				'eff',		struct( ...
					'file',		'', ...
					'path',		'', ...
					'index',	0 ... 
					) ...
				) ...
			), ...
		'units',		struct( ...
			'freq',			s.tabs.settings.units.freq.default, ...
			'phase',		s.tabs.settings.units.phase.default ...
			), ...
		'interp',		struct( ...
			'function',		s.tabs.settings.interp.function.default, ...
			'method',		s.tabs.settings.interp.method.default, ...
			'freq',			[], ...
			'prim',			[], ...
			'sec',			[] ...
			), ...
		'sParam',		struct( ...
			'freqRange',	[], ...
			'axesVisible',	false, ...
			'graphType',	s.tabs.sParam.plotSett.graphType.default, ...
			'replacement',	s.tabs.sParam.plotSett.replacement.default, ...
			'markerFreq',	struct( ...
				'options',		s.tabs.sParam.plotSett.marker.options, ...
				'selected',		s.tabs.sParam.plotSett.marker.default ...
				) ...
			), ...
		'patt',		struct( ...
			'graphType',	s.tabs.patt.plotSett.graphType.default, ...
			'axesVisible',	false, ...
			'firstAxis',	struct( ...
				'options',		{s.tabs.patt.plotSett.axis.options}, ...
				'selected',		s.tabs.patt.plotSett.axis.default ...
				), ...
			'secondAxis',	struct( ...
				'options',		{s.tabs.patt.plotSett.axis.options(... 
									1 : length(s.tabs.patt.plotSett.axis.options) ~= ...
									s.tabs.patt.plotSett.axis.default)}, ...
				'selected',		s.tabs.patt.plotSett.axis.default ...
				), ...
			'fixed',		struct( ...
				'variable',		'', ...		% see below
				'options',		'', ...
				'selected',		1 ...
				), ...
			'polarization', s.tabs.patt.plotSett.polarization.default, ...
			'value',		s.tabs.patt.plotSett.value.default, ...
			'replacement',	s.tabs.patt.plotSett.replacement.default, ...
			'overlay',		struct( ...
				'options',		'', ...
				'selected',		1 ...
				) ...
			), ...
		'eff',		struct( ...
			'data',			struct(...
				'calc',			false, ...
				'total',		[], ...
				'radiation',	[], ...
				'matching',		[], ...
				's11',			[], ...
				'freq',			[] ...
				), ...
			'unit',			s.tabs.eff.plotSett.unit.default, ...
			'axesVisible',	false, ...
			'replacement',	s.tabs.eff.plotSett.replacement.default ...
			), ...
		'plotting',	struct( ...
			'figures',		[] ...
			) ...
		);
	
	d.patt.fixed.variable = d.patt.secondAxis.options{...
		1 : length(d.patt.secondAxis.options) ~= ...
		d.patt.secondAxis.selected};
	
end