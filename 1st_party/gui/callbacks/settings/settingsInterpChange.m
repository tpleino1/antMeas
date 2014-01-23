function settingsInterpChange(~, ~, gui, static, qty, byCount)
% A callback to dynamically update interpolation table when it is modified
% by the user.
	
	gui = guidata(gui.window);
	
	% Debugging values
	v = gui.dynamic.original.(qty);
	if gui.debug && isempty(v)
		d = struct(...
			'freq',		(700:40:1100)' * 1e6, ...
			'prim',		(-180:10:180)', ...
			'sec',		(0:-10:-180)' ...
			);
		v = d.(qty);
		clear d;
	end
	
	% Shorthands
	vMin = str2double(get(gui.settingsTab.interpPanel.([qty, 'MinEdit']), 'String'));
	vMax = str2double(get(gui.settingsTab.interpPanel.([qty, 'MaxEdit']), 'String'));
	vStep = abs(str2double(get(gui.settingsTab.interpPanel.([qty, 'StepEdit']), 'String')));
	vCount = round(abs(str2double(get(gui.settingsTab.interpPanel.([qty, 'CountEdit']), 'String'))));
	e = abs(static.tabs.settings.maxExtrap); % Allow some extrapolation
	
	% Freq. vs. phase
	if strcmp(qty, 'freq')
		unit = 'freq';
		vMin = abs(vMin);
		vMax = abs(vMax);
	else
		unit = 'phase';
	end
	
	v = v / static.tabs.settings.units.(unit).coeffs(gui.dynamic.units.(unit));
	
	% Sanity check
	if (~isfinite(vMin) || vMin < min(v) - e * (max(v) - min(v)) || ...
			vMin > max(v) + e * (max(v) - min(v)))
		vMin = min(v);
	end
		
	if (~isfinite(vMax) || vMax > max(v) + e * (max(v) - min(v)) || ...
			vMax < min(v) - e * (max(v) - min(v)))
		vMax = max(v);
	end
	
	% Count is changed
	if byCount
		if (~isfinite(vCount) || vCount < 1)
			vCount = length(v);
		end

		if (vMax == vMin)
			vStep = 1;
			vCount = 1;
		elseif (vCount == 1)
			vStep = 1;
			vMin = mean([vMax, vMin]);
			vMax = vMin;
		else
			vStep = (vMax - vMin) / (vCount - 1);
		end
	% Min, max or step is changed	
	else
		if (~isfinite(vStep) || vStep <= 0 || (vStep > (max(v) - min(v))))
			vStep = abs(mean(diff(v)));
		end

		vVector = vMin : vStep : vMax;
		vCount = length(vVector);

		if (vMax < max(vVector))
			vCount = vCount + 1;
		end
	end
	clear v;
	
	% Update GUI
	set(gui.settingsTab.interpPanel.([qty, 'MinEdit']), ...
		'String',		num2str(vMin, '%g'));
	set(gui.settingsTab.interpPanel.([qty, 'MaxEdit']), ...
		'String',		num2str(vMax, '%g'));
	set(gui.settingsTab.interpPanel.([qty, 'StepEdit']), ...
		'String',		num2str(vStep, '%g'));
	set(gui.settingsTab.interpPanel.([qty, 'CountEdit']), ...
		'String',		int2str(vCount));
	
	% Total number of complex points in one pattern matrix
	fCount = abs(str2double(get(gui.settingsTab.interpPanel.freqCountEdit, 'String')));
	pCount = abs(str2double(get(gui.settingsTab.interpPanel.primCountEdit, 'String')));
	sCount = abs(str2double(get(gui.settingsTab.interpPanel.secCountEdit, 'String')));
	set(gui.settingsTab.interpPanel.totalEdit, ...
		'String',		num2str(fCount * pCount * sCount, '%g'));
	
	guidata(gui.window, gui);
	
end
