function pattChangeGraph(~, ~, gui, static, elem)
% A callback to update the Pattern tab when an input is changed.
%	elem values:	1 = Graph type,		2 = First axis, 
%					3 = Second axis,	4 = Plot value

	gui = guidata(gui.window);
	
	% Shorthands
	fCoeff = static.tabs.settings.units.freq.coeffs(gui.dynamic.units.freq);
	fUnit = static.tabs.settings.units.freq.units{gui.dynamic.units.freq};
	pCoeff = static.tabs.settings.units.phase.coeffs(gui.dynamic.units.phase);
	pUnit = static.tabs.settings.units.phase.units{gui.dynamic.units.phase};
	
	% Debugging values
	if gui.debug	
		freq = (700:40:1100)' * 1e6;
		prim = (-180:10:180)';
		seco = (-180:10:0)';
	else
		freq = gui.dynamic.interpolated.freq;
		prim = gui.dynamic.interpolated.prim;
		seco = gui.dynamic.interpolated.sec;
	end
	
	freq = freq / fCoeff;
	prim = prim / pCoeff;
	seco = seco / pCoeff;
	
	% Shorthands
	choices = struct( ...
		'freq',	{strcat(cellfun(@num2str, num2cell(freq), ...
					'UniformOutput', false), [' ', fUnit])}, ...
		'prim',	{strcat(cellfun(@num2str, num2cell(prim), ...
					'UniformOutput', false), [' ', pUnit])}, ...
		'seco',	{strcat(cellfun(@num2str, num2cell(seco), ...
					'UniformOutput', false), [' ', pUnit])} ...
		);
	clear freq prim seco;
	
	special = false; % for freq & polar -combination
	
	% Update secondAxisLabel 
	% (run only when graphType is changed)
	if (elem == 1)
		gui.dynamic.patt.graphType = ...
			get(gui.pattTab.settPanel.graphSelect, 'Value');
		% Overlay / Second Axis
		set(gui.pattTab.settPanel.secondAxisLabel, 'String', ...
			static.tabs.patt.settPanel.secondLabel.options{...
				1 + ~(gui.dynamic.patt.graphType > 2)});
			
		% One cannot use frequency as the angle in polar plots
		if gui.dynamic.patt.graphType == 2
			gui.dynamic.patt.firstAxis.options = ...
				static.tabs.patt.plotSett.axis.options(1 : end - 1);
			if gui.dynamic.patt.firstAxis.selected == 3
				gui.dynamic.patt.firstAxis.selected = 1;
				set(gui.pattTab.settPanel.firstAxisSelect, ...
					'Value',	gui.dynamic.patt.firstAxis.selected);
			end
			special = true; % special case, need to update later elements
		else
			gui.dynamic.patt.firstAxis.options = ...
				static.tabs.patt.plotSett.axis.options;
		end
		% Set options
		set(gui.pattTab.settPanel.firstAxisSelect, ...
			'String',	gui.dynamic.patt.firstAxis.options);
	end
	
	% Update secondAxisSelect
	% (run when firstAxis is changed or when special case)
	if (elem == 2 || special)
		% Update selection
		gui.dynamic.patt.firstAxis.selected = ...
			get(gui.pattTab.settPanel.firstAxisSelect, 'Value');
		
		% Set second selection options
		gui.dynamic.patt.secondAxis.selected = 1;
		gui.dynamic.patt.secondAxis.options = ...
			static.tabs.patt.plotSett.axis.options( ... 
				1 : length(static.tabs.patt.plotSett.axis.options) ~= ...
					gui.dynamic.patt.firstAxis.selected);
		set(gui.pattTab.settPanel.secondAxisSelect, ...
			'String',		gui.dynamic.patt.secondAxis.options, ...
			'Value',		gui.dynamic.patt.secondAxis.selected);
	end
	
	% Update fixedLabel and fixedSelect
	% (run when either firstAxis or secondAxis is changed, or when special case)
	if ((elem == 2) || (elem == 3) || special)
		% Update dynaic
		gui.dynamic.patt.secondAxis.selected = ...
			get(gui.pattTab.settPanel.secondAxisSelect, 'Value');
		% Set fixed label & update selection
		gui.dynamic.patt.fixed.variable = gui.dynamic.patt.secondAxis.options{...
			1 : length(gui.dynamic.patt.secondAxis.options) ~= ...
			gui.dynamic.patt.secondAxis.selected};
		gui.dynamic.patt.fixed.options = ...
			choices.(lower(gui.dynamic.patt.fixed.variable(1:4)));
		gui.dynamic.patt.fixed.selected = 1;

		set(gui.pattTab.settPanel.fixedLabel, ...
			'String',		sprintf(static.tabs.patt.settPanel.fixedLabel, ...
								lower(gui.dynamic.patt.fixed.variable)));
		set(gui.pattTab.settPanel.fixedSelect, ...
			'String',		gui.dynamic.patt.fixed.options, ...
			'Value',		gui.dynamic.patt.fixed.selected);
	end
	clear special;
	
	% Update overlayList
	% (run when either graphType, firstAxis or secondAxis is changed)
	if (elem < 4)
		gui.dynamic.patt.overlay.selected = ...
			get(gui.pattTab.settPanel.overlayList, 'Value');
		% Disable for 2D plots
		if gui.dynamic.patt.graphType > 2
			gui.dynamic.patt.overlay.options = {static.tabs.patt.settPanel.noneText};
			e = 'off';
			gui.dynamic.patt.overlay.selected = 1;
		else
			e = 'on';
			% For added robustness
			if (elem > 1) || isequal(gui.dynamic.patt.overlay.options, ...
				{static.tabs.patt.settPanel.noneText}) || isempty(gui.dynamic.patt.overlay.options)
				gui.dynamic.patt.overlay.options = ...
					choices.(lower(gui.dynamic.patt.secondAxis.options{...
						gui.dynamic.patt.secondAxis.selected}(1:4)));
				gui.dynamic.patt.overlay.selected = 1;
			end
		end

		% Update element
		set(gui.pattTab.settPanel.overlayList, ...
			'String',		gui.dynamic.patt.overlay.options, ...
			'Min',			1, ...
			'Max',			length(gui.dynamic.patt.overlay.options), ...
			'Value',		gui.dynamic.patt.overlay.selected, ...
			'Enable',		e ...
			);
	end
	
	% Update replacementSelect
	% (run when either graphType or plotValue is changed)
	if (elem == 1 || elem == 4)
		gui.dynamic.patt.value = get(gui.pattTab.settPanel.valueSelect, 'Value');
		% Disable docked graphs for dual-plots & surface/pcolor
		if (gui.dynamic.patt.value > 3 || gui.dynamic.patt.graphType == 4)
			set(gui.pattTab.settPanel.replacementSelect, 'Value', 2);
			set(gui.pattTab.settPanel.replacementSelect, 'Enable', 'off');
		% Restore if previously disabled
		elseif strcmpi(get(gui.pattTab.settPanel.replacementSelect, 'Enable'), 'off')
			set(gui.pattTab.settPanel.replacementSelect, 'Value', 1);
			set(gui.pattTab.settPanel.replacementSelect, 'Enable', 'on');
		end
	end

	guidata(gui.window, gui);
	
end
