
public class Dayblock implements Comparable<Dayblock>{
    
    char[] days;
    
        public Dayblock(char[] givenDays) {
                     
            for (char c: givenDays){
              /* if (c != 'M' && c != 'T' && c != 'W' && c != 'R' && c != 'F')
                    throw new Exception("This is not a day!"); */
		// already handled in lexer
            }
           
            days = givenDays;
        }
       
	public Dayblock() {

	}

	public boolean has(char d)
	{
		Boolean exists = false;
		for (char x : days)
		{
			if(x == d)
			{
				exists = true;
				break;
			}
		}
		return exists;
	}
        
        public boolean add(char c) throws Exception
        {
            //returns true if the day was already in the dayblock
            //returns false if day was added successfully
            //returns error if day requested is not M, T, W, R or F
            
            if(this.has(c))
                return false;
            else if(c != 'M' && c != 'T' && c != 'W' && c != 'R' && c != 'F')
            {
                throw new Exception("This is not a day!");
            }
            else
            {
                char[] temp = new char[days.length + 1];
                for (int i=0; i < days.length; i++)
                    temp[i] = days[i];
                temp[temp.length - 1] = c;
                days = temp;
                return true;
            }
        }

        public boolean equals(Object o){
		if (this == o) {
			return true;
		}
		if (o == null || this.getClass() != o.getClass()) {
			return false;
		}
		Dayblock that = (Dayblock)o;
		if (this.days.length != that.days.length){
			return false;
		}
		
                for (int i = 0; i < days.length; i++ ){
			if (this.days[i] != that.days[i]){
				return false;
			}
		}
		return true;
	}
        
	public String toString() {
		String dayString = "";
		for (char x: days)
		{
			dayString += x;
		}
                
                dayString += "";
                return dayString;
	}
        
        public int compareTo(Dayblock that){
		if (this.equals(that)){
			return 0;
		}
		else {
			return -1;
		}
	}
}
