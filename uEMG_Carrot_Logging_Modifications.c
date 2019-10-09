/**< Perform the signal reading & analysis 
@returns bool True if process complete
*/
bool sensor_uemg_1_ch::process(void)
{
	// read the signal at the ADC pin
	uint16_t raw = ADC_read_pin(_ch[CH0].pin);
	uint64_t t = millis();
	
	printf("%lu,",t); //for some unknown reason printing both t and raw in the same printf doesn't work.
	printf("%d\n",raw);
	
}