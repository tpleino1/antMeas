function effExport(hObject, ~, gui, static)
% Exports antenna efficiency data in the following format:
% 	! << filename >>
% 	! Total efficiency (in percent) and S11 data (in dB)
% 	!
% 
% 	! f (MHz)		eff(%)		abs(S11)
% 	<< freq >>		<< eff >>	<< s11 >>	

	gui = guidata(gui.window);
	
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
	
	try
		% Open 'Save File' -dialog
		if ~isempty(hObject)
			[fn, pn] = uiputfile({ static.tabs.eff.io.ext, ...
				static.tabs.eff.io.desc }, ...
				static.tabs.eff.io.dialogTitle);
		else
			fn = gui.dynamic.io.export.file;
			pn = gui.dynamic.io.export.path;
		end

		% Write to file (header + data)
		fileH = fopen([pn, fn], 'w');
		fprintf(fileH, '! %s (%s)\n', fn, datestr(now, static.general.date.full));
		clear pn fn;
		fprintf(fileH, '! Total efficiency (in percent) and S11 data (in dB)\n');
		fprintf(fileH, '! \n');
		fprintf(fileH, '\n');
		fprintf(fileH, '!%12s %12s %12s\n', 'f(MHz)', 'eff(%)', 'abs(S11)');
		
		for i = 1 : length(gui.dynamic.eff.data.freq)
			fprintf(fileH, ' %12.2f %12.6f %12.6f\n', ...
				gui.dynamic.eff.data.freq(i) / 1e6, ...
				gui.dynamic.eff.data.total(i) * 100, ...
				20 * log10(gui.dynamic.eff.data.s11(i)));
		end

		fclose(fileH);
			
	catch err
		fclose('all');
		if gui.debug
			getReport(err);
		end
	end
	
	guidata(gui.window, gui);
	
end