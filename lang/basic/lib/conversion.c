/* $Header$ */

int _cint(f) double f;
{
	int r;
	if( f<-32768 || f>32767) error(4);
	if(f<0)
		r= f-0.5;
	else	r= f+0.5;
	return(r);
}

double _trunc(f)
double f;
{
	long d;
	d=f;
	f=d;
	return( f );
}

double _fcint(f) double f;
{
	long r;
	if(f<0){
		r= -f;
		r= -r -1;
	}else	r= f;
	f=r;
	return(f);
}
int _fix(f)
double f;
{
	int r;

	if( f<-32768.0 || f>32767.0) error(4);
	r= _sgn(f) * _fcint((f>0.0? f : -f));
	return(r);
}
