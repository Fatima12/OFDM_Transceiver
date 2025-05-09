function [ completeDatatemp , pilots ] = p_removal( ModData  )

    completeDatatemp = complex(zeros(1,48));
    pilots = complex(zeros(1,4));

    pilots(1) = ModData(12);
    pilots(2) = ModData(26);
    pilots(3) = ModData(40);
    pilots(4) = ModData(54);
    
    completeDatatemp(1:5) = ModData(7:11);
    
    completeDatatemp(6:18) = ModData(13:25);
    
    completeDatatemp(19:24) = ModData(27:32);
    
    completeDatatemp(25:30) = ModData(34:39);

    completeDatatemp(31:43) = ModData(41:53);
    
    completeDatatemp(44:48) = ModData(55:59);
    
end

