function [patchH, lineH, rLabelH, iLabelH] = initSmithChart( axesH, varargin )
% initSmithChart( axesH, cfg ) converts current axes suitable for smith 
% charting. "Identical" to the smithchart -function provided in the RF
% tool box, but as a plot, not through an object
%
% Input:	axesH		axes handle
%			varargin	'key', value -pairs for configuration 
%							(case-sens, see below). 
%
% 	Settings available through the use of varargin, 
%	and their default values:
% 		type			Type of Smith chart: 'Z', 'Y', 'ZY', or 'YZ'
% 		values			2*N matrix for the circles
% 		color			Color for the 
% 							[main chart; sub chart]
% 		lineWidth		Line width for the 
% 							[main chart, sub chart]
% 		lineStyle		Line type for the
% 							{main chart, sub chart}
% 		labelShow		Visibility of the line labels: true/false
% 		labelSize		Label size
% 		labelColor		Label color
%
%	Plot as follows: plot(axesH, real(s), imag(s), ...);

	cfg = configValues(varargin); % Config values

	% Real-axis labels with leading zeros removed, if given in-order
	rLabelStr = cellfun(@num2str, num2cell(cfg.values(1, :)), ...
			'UniformOutput', false);
	
	for i = 1 : size(cfg.values, 2)
		if rLabelStr{i}(1) == '0'
			rLabelStr{i} = rLabelStr{i}(2:end);
		else
			break;
		end
	end
	
	% Type of the main chart
	if cfg.type(1) == 'y'
		rLabelVal = 1 ./ cfg.values(1, :);
	else
		rLabelVal = cfg.values(1, :);
	end	
	rLabelVal = (rLabelVal - 1) ./ (rLabelVal + 1);
	
	% Imag-axis labels with leading zeros removed, if given in-order
	iLabelStr = strcat(cellfun(@num2str, num2cell(cfg.values(1, :)), ...
			'UniformOutput', false), 'j');
	for i = 1 : size(cfg.values, 2)
		if iLabelStr{i}(1) == '0'
			iLabelStr{i} = iLabelStr{i}(2:end);
		else
			break;
		end
	end
	
	iLabelStr = ['\infty', strcat('+', iLabelStr(end : -1 : 1)), ...
		'0', strcat('-', iLabelStr)];
	
	% Position of the Imag-labels
	iLabelAng = 1i * [cfg.values(1, end : -1 : 1), 0, -cfg.values(1, 1 : end)];
	iLabelAng = [0, angle((iLabelAng - 1) ./ (iLabelAng + 1))];
	
	if cfg.type(1) == 'y'
		iLabelAng = iLabelAng + pi;
	end
	
	% Init, enforcing arc-limits
	r = sort([0, logspace(-2, 2, 1001), cfg.values(2, :)]);
	p = (0 : 360) / 180 * pi;
	
	axes(axesH);
	axis ([-1 1 -1 1] * (1 + cfg.labelImagOff)); % To avoid overlapping title
	axis equal;
	axis off;
	grid off;
	set(axesH, 'nextPlot', 'replace');
	
	% Background
	patchH = patch(...
		'XData',		1 * cos(p), ...
		'YData',		1 * sin(p), ...
		'EdgeColor',	cfg.labelColor, ...
		'FaceColor',	1 * [1 1 1] ...
		);
	
	set(axesH, 'nextPlot', 'add');
	lineH = zeros(length(cfg.type), 4 * size(cfg.values, 2));
	
	% Plot lines (Imag & Real)
	for i = length(cfg.type) : -1 : 1
		for j = 1 : size(cfg.values, 2)
			z = r(r <= cfg.values(2, j)) + 1i * cfg.values(1, j);
			if cfg.type(i) == 'y'
				z = 1 ./ z;
			end
			s = (z - 1) ./ (z + 1);
			lineH(i, 0 * size(cfg.values, 2) + j) = ...
				plot(real(s), imag(s), ...
				'Color',		cfg.color(i, :), ...
				'lineWidth',	cfg.lineWidth(i), ...
				'lineStyle',	cfg.lineStyle{i} ...
				);
			lineH(i, 1 * size(cfg.values, 2) + j) = ...
				plot(real(s), -imag(s), ...
				'Color',		cfg.color(i, :), ...
				'lineWidth',	cfg.lineWidth(i), ...
				'lineStyle',	cfg.lineStyle{i} ...
				);
			
			z = cfg.values(1, j) + 1i * r(r <= cfg.values(2, j));
			if cfg.type(i) == 'y'
				z = 1 ./ z;
			end
			s = (z - 1) ./ (z + 1);

			lineH(i, 2 * size(cfg.values, 2) + j) = ...
				plot(real(s), imag(s), ...
				'Color',		cfg.color(i, :), ...
				'lineWidth',	cfg.lineWidth(i), ...
				'lineStyle',	cfg.lineStyle{i} ...
				);
			lineH(i, 3 * size(cfg.values, 2) + j) = ...
				plot(real(s), -imag(s), ...
				'Color',		cfg.color(i, :), ...
				'lineWidth',	cfg.lineWidth(i), ...
				'lineStyle',	cfg.lineStyle{i} ...
				);
		end
	end
	clear i j;
	
	% Real & Imag -axes
	lineH(end+1) = line([-1 1], [0 0], ...
		'Color',		cfg.color(1, :), ...
		'lineWidth',	cfg.lineWidth(1), ...
		'lineStyle',	cfg.lineStyle{1} ...
		);
	
	lineH(end+1) = line(1 * cos(p), 1 * sin(p), ...
		'Color',		cfg.labelColor, ...
		'lineWidth',	1, ...
		'lineStyle',	'-' ...
		);
	
	% Imag & Real Labels
	iLabelH = zeros(length(iLabelStr), 1);
	for i = 1 : length(iLabelStr)
		iLabelH(i) = text( ...
			(1 + cfg.labelImagOff) * cos(iLabelAng(i)), ...
			(1 + cfg.labelImagOff) * sin(iLabelAng(i)), ...
			iLabelStr{i}, ...
			'HorizontalAlignment',	'Center', ...
			'VerticalAlignment',	'Middle', ...
			'Rotation',				...
				cfg.labelImagRot * (iLabelAng(i) / pi * 180 - 90 - ...
					180 * cfg.labelImagFlip * (iLabelAng(i) < 0)) ...
			);
	end
	
	rLabelH = zeros(length(rLabelStr), 1);
	for i = 1 : length(rLabelStr)
		rLabelH(i) = text( ...
			real(rLabelVal(i)) + cfg.labelRealXOff, ...
			imag(rLabelVal(i)) + cfg.labelRealYOff, ...
			rLabelStr{i}, ...
			'HorizontalAlignment',	'Center', ...
			'VerticalAlignment',	'Middle', ...
			'Rotation',				cfg.labelRealRot ...
			);
	end

	set(axesH, 'nextPlot', 'replace');

	
	function [cfg] = configValues(varargin)

		% Default Values
		cfg = struct( ... 
			'type',				'z', ... % z, y, zy or yz
			'values',			[	0.2		0.5		1	2	5; ...
									1		2		5	5	100		], ...
			'color',			[	0.5 * [1 1 1]; ...
									0.7 * [1 1 1]	], ...
			'lineWidth',		[0.5, 0.5], ...
			'lineStyle',		{{'-', ':'}}, ...
			'labelShow',		true, ...
			'labelSize',		10, ...
			'labelColor',		0 * [0 0 0], ...
			'labelImagOff',		0.08, ...
			'labelRealXOff',	0.05, ...
			'labelRealYOff',	0.04, ...
			'labelRealRot',		0, ... % angle in degress
			'labelImagRot',		false, ...
			'labelImagFlip',	true ...
			);

		if isempty(varargin)
			return;
		else
			varargin = varargin{1};
		end

		% User Overridden Values
		k = 1;
		while k <= length(varargin)
			if isfield(cfg, varargin{k})
				cfg.(varargin{k}) = varargin{k + 1};
				k = k + 2;
			else
				warning('myApp:UnknownProperty', ...
					['Property ''', varargin{k}, ''' unknown.'])
				k = k + 1;
			end
		end
		
		cfg.type = lower(cfg.type);
		cfg.labelShow = logical(cfg.labelShow);
		cfg.labelImagRot = logical(cfg.labelImagRot);
		cfg.labelImagFlip = logical(cfg.labelImagFlip);
		
		if size(cfg.values, 1) ~= 2
			cfg.values = [	0.2		0.5		1	2	5; ...
							1		2		5	5	100		];
		end

	end

end

