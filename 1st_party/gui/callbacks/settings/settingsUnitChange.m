function settingsUnitChange(~, ~, gui, static, unit)
	
	gui = guidata(gui.window);
	
	oldUnit = gui.dynamic.units.(unit);
	newUnit = get(gui.settingsTab.unitPanel.(strcat(unit, 'Select')), 'Value');
	
	% Do nothing if the same unit
	if oldUnit ~= newUnit
		
		% Update unit
		gui.dynamic.units.(unit) = newUnit;
		
		% Shorthands for clarity
		oldCoeff = static.tabs.settings.units.(unit).coeffs(oldUnit);
		newCoeff = static.tabs.settings.units.(unit).coeffs(newUnit);

		% The count field is not affected by scaling
		g = {'Min', 'Max', 'Step'}';

		% Phase affects both prim & sec
		if strcmp(unit, 'freq')
			f = {'freq'};
		else
			f = {'prim', 'sec'};
		end

		% Scale min, max and step values with atleast some 'finesse'
		for i = 1 : length(f)
			set(gui.settingsTab.interpPanel.([f{i}, 'Label']), 'String', ...
				sprintf(static.tabs.settings.interpPanel.([f{i}, 'Label']), ...
				static.tabs.settings.units.(unit).units{gui.dynamic.units.(unit)}));

			v = zeros(size(g));

			for j = 1 : length(g)
				v(j) = str2double( get( gui.settingsTab.interpPanel.( ...
					[f{i}, g{j}, 'Edit']), 'String' ) );
			end

			% Freq min, max & step are always non-negat., 
			% prim/sec step is always positive, min & max can be negat.
			if strcmp(unit, 'freq')
				v = abs(v);
			else
				v(3) = abs(v(3));
			end
	
			for j = 1 : length(g)
				if isfinite(v(j))
					str = num2str(v(j) * oldCoeff / newCoeff, '%g');
				else
					str = '';
				end
				set(gui.settingsTab.interpPanel.([f{i}, g{j}, 'Edit']), ...
					'String', str);
			end

		end
		
		% Query 'unit update' for S-param & Pattern tabs
		% (since they use semi-static units)
		gui.dynamic.tabDefaults(3:4) = [true true];
		
	end
	
	guidata(gui.window, gui);
	
end
