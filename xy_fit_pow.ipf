#pragma rtGlobals=1

Function sum_sqr(inWave)
	Wave inWave
	Variable sum_ss
	duplicate inWave, tmp_wave
	tmp_wave = inWave^2
	sum_ss = sum(tmp_wave)
	KillWaves /Z tmp_wave
	return sum_ss
End

Function xy_fit_pow(xWave, yWave)
	Wave xWave, yWave
	String fit_func_name, traceName
	Variable r2, rmse, xmax, ymax
	String stat_txt, r2str, rmsestr
	//Check if waves have the same number of elements
	if  (numpnts(xWave) != numpnts(yWave))
		Print "Input Waves must have the same length"
		return 0
	endif
	
	//calculate axis range
	xmax = ceil(WaveMax(xWave)/10)*10
	ymax = ceil(WaveMax(yWave)/100)*100
	
	//Create XY scatter plot
	Display yWave vs xWave ; DelayUpdate
	ModifyGraph width = 72*3 ; DelayUpdate //5 inches
	ModifyGraph height = 72*3 ; DelayUpdate // 5 inches
	if (numpnts(yWave) > 500)
		ModifyGraph mode = 2; DelayUpdate //Change to dots
		ModifyGraph lsize=1;DelayUpdate
	else
		ModifyGraph mode = 3; DelayUpdate
		ModifyGraph marker = 19; DelayUpdate
		ModifyGraph msize = 1.2; DelayUpdate
	endif
	
	ModifyGraph rgb=(0,0,0); DelayUpdate //Change color of wave to black
	ModifyGraph standoff = 0; DelayUpdate //Have axis right at zero
	SetAxis left 0,ymax ; DelayUpdate  //Set axis range
	SetAxis bottom 0,xmax; DelayUpdate //Set axis range
	//Label bottom "Lorey's Height (m)"; DelayUpdate
	//Label left "Aboveground Biomass (Mg/ha)";
	
	//Fit power law
	Duplicate /O yWave, tmp_residual
	Duplicate /O yWave, tmp_fity
	K0=0;
	CurveFit /X=1 /H="100" /N=1 /NTHR=0 Power yWave /X=xWave /D /R=tmp_residual /A=0; DelayUpdate
	//fitted function wave name
	ModifyGraph rgb=(0,0,0); DelayUpdate
	ModifyGraph lsize = 1.0; DelayUpdate
	
	Duplicate /O yWave, tmp_sst
	tmp_sst = yWave - mean(yWave)
	r2 = 1 - sum_sqr(tmp_residual)/sum_sqr(tmp_sst)
	Duplicate /O tmp_residual, tmp_res2
	tmp_res2 = tmp_residual * tmp_residual
	rmse = sqrt(mean(tmp_res2))
	
	sprintf rmsestr, "%5.1f", rmse
	sprintf r2str, "%4.2f", r2
	stat_txt = "R\\S2\\M= " + r2str + "\rRMSE=" + rmsestr
	TextBox /F=0 /C /N=text0 /X=65 /Y=5 stat_txt
	
	
End
