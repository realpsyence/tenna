// 40m capacitive-hat loaded vertical dipole.
// Optimizes for inductance in the lumped parallel load (beta match?)
real r, la, lb, lp, ca, width, length;

void cap_hat (real arm_len, real height, int n, int perimeter)
{
	real rho, phi, sigma;
	int i;
	element e;
	i = 1;
	rho = 2*pi / n;
	phi = rho;
	sigma = 5960000;
	
	repeat(n)
	{
		e = wire (0, 0, height, arm_len*cos(phi), arm_len*sin(phi), height, 0.5", 13);
		phi = phi + rho;
		conductivity(e, sigma);
	}
	phi = rho;
	if(perimeter)
	repeat(n)
	{
		e = wire(arm_len*cos(phi), arm_len*sin(phi), height, arm_len*cos(phi + rho), arm_len*sin(phi + rho), height,
		 0.5", 13);
		phi = phi + rho;
		conductivity(e, sigma);
	}
}

model ( "madhat40m" )
{
	real height, sigma;
 	int perimeter;
	int segments, num_arms;
	element center;
		
	height = 1.4 ;

	segments = 21 ;
	num_arms = 4;
	
	perimeter = 0; // don't use a perimeter wire
	sigma = 5960000;
	
	center = wire(0, 0, height, 0, 0, height+length, 1", segments);

	cap_hat(width, height, num_arms, perimeter);
	cap_hat(width, height+length, num_arms, perimeter);

	conductivity(center, sigma);
	r = 0.9;
	lumpedParallelLoad ( center, 10000, la, 0);
	//lumpedSeriesLoad(center, r, lp, ca);
	voltageFeed( center, 1, 0 );
	setFrequency ( 7.100 );

}

control()
{
	real din, cur, prev, dca, dw, dlen;
	int run_in, run_out;
	
	run_out = 10;
	run_in = 3;
	
	din = 1u ;
	la = 15u;
	//lp = 0.73u;
	width = 0.95 ;
	length = 4.0 ;
	dw = 0.1;
	dlen = 0.1;
	
	repeat(run_out) {
			prev = 999.9;

	repeat (run_in*3) {
		runModel();
		cur = vswr( 1 );
		printf("la = %.10f jX = %.5f\n" , la, cur);
		if( fabs(cur) > fabs(prev) ) din = -din * 0.75;
		prev = cur;
		la = la + din;
		//pause( 1.0 );
	}

	prev = 999.9;
	repeat (0) {
		runModel();
		cur = vswr(1);
		printf("width = %.10f vswr = %.5f\n", width, cur);
		if( cur > prev ) dw = -dw *0.5;
		prev = cur;
		width = width + dw;
	}
	
	prev = 999.9;
	repeat(0) {
		runModel();
		cur = vswr(1);
		printf("length = %.10f vswr = %.5f\n", length, cur);
		if( cur > prev ) dlen = -dlen *0.5;
		prev = cur;
		length = length + dlen;
	}
	}
}

