function [ completeData ] = p_insertion( ModData , p )

    completeDatatemp = complex(zeros(1,53));
    completeDatatemp(1:5) = ModData(1:5);
    completeDatatemp(6) = 1*p;                  %pilot                    
    completeDatatemp(7:19) = ModData(6:18);
    completeDatatemp(20) = 1*p;
    completeDatatemp(21:26) = ModData(19:24);
    completeDatatemp(27) = 0;
    completeDatatemp(28:33) = ModData(25:30);
    completeDatatemp(34) = 1*p;
    completeDatatemp(35:47) = ModData(31:43);
    completeDatatemp(48) = -1*p;
    completeDatatemp(49:53) = ModData(44:48);
   
    completeData = complex(zeros(1,64));
    completeData(7:59) = completeDatatemp;
        
end

