/*用了个宏，方便少量多次*/
%macro makesets; 

/*log太长，输出到某个文件方便查看*/
dm 'clear log';
proc printTo log="&path\saslog.log" new;

/*这句话用到好几次，设个宏变量*/
/*set macro variable*/s
%let infilestatements=infile nosense
	filevar=filevar truncover 
	encoding="utf-8" end=lastobs LRECL=700;

/*一共多少个文件*/
proc sql noprint;
	select count(*) into :CountOfFiles
from Dir.DirInfo;
quit;

%do CountOfMacro= 1 %to &CountOfFiles;

/*生成每个文件的路径*/	
	data _null_;
		Point=&CountOfMacro;
		set Dir.Dirinfo point=Point;
		call symput("filename",
			catx('\',"&path\behavior",PriDirName,SecDirname));
		call symput("ID_M",id);
		stop;
	run;

/*主要输出RecData，有些文件仅两行记录，输出到NullRecData*/
data Dir.RecData Dir.NullRecData;
		drop  StartPos  CountOfPair Position Pair_Str Head
			i Length_Pair Pair_Head Pair_Body Rec_Str Temp_Str;
		ID=symget("ID_M");
		length Temp_Str $1000;
		retain Last L_Start Temp_Str;

		filevar=symget("filename");

		/*data步第一次迭代，读取前两行*/
		if _n_ =1 then do;
			&infilestatements;
			input @8 Last;
			&infilestatements;
			input @11 L_Start ANYDTDTM19.;	
			format L_Start Datetime.;
			if lastobs=1 then output Dir.NullRecData;
		end;

		/*只有两行的话洗洗睡了*/
		if lastobs=0;

		&infilestatements;
		input @1 Head $1. @;

		/*不以T开头的记录都不是好人*/
		if Head="T" then do;
				if _n_ >1 then do;

					/*算算有几对*/
					CountOfPair=count(Temp_Str,"[=]")+1;
					StartPos=1;

					/*把对对们拆拆开*/
					do i=1 to CountOfPair;
						Position=find(Temp_Str,"[=]",StartPos); 
						if Position=0 then Position=length(Temp_Str)+1;
						Length_Pair=Position-StartPos;
						Pair_Str=substr(Temp_Str,StartPos,Length_Pair);
						StartPos=Position+3;
						Pair_Head=substr(Pair_Str,1,1);
						Pair_Body=substr(Pair_Str,5);
						select(Pair_Head);
							when('T') Rec_T=input(Pair_Body,8.);
							when('P') Rec_P=Pair_Body;
							when('I') Rec_I=Pair_Body;
							when('U') Rec_U=Pair_Body;
							when('A') Rec_A=Pair_Body;
							when('B') Rec_B=Pair_Body;
							when('V') Rec_V=Pair_Body;
							when('W') Rec_W=Pair_Body;
							when('N') Rec_N=Pair_Body;
							when('C') Rec_C=Pair_Body;
							otherwise Rec_Other=Pair_Body;
						end;
					end;
					
					output Dir.RecData;
				end;
				Temp_Str="";  

				/*读入一整行*/
				input @1 Rec_Str $700.;
				Temp_Str=Rec_Str; 
		end;
		else do;
			input @1 Rec_Str $700.;
			Temp_Str=left(trim(Temp_Str))||left(trim(Rec_Str));
		end;

	/*提取字段都滞后一行，最后一行的话在开个小灶*/
	if lastobs=1 and _n_ >1 then do;

					/*这里重复了，应该可以简化下*/
					CountOfPair=count(Temp_Str,"[=]")+1;
					StartPos=1;
					do i=1 to CountOfPair;
						Position=find(Temp_Str,"[=]",StartPos); 
						if Position=0 then Position=length(Temp_Str)+1;
						Length_Pair=Position-StartPos;
						Pair_Str=substr(Temp_Str,StartPos,Length_Pair);
						StartPos=Position+3;
						Pair_Head=substr(Pair_Str,1,1);
						Pair_Body=substr(Pair_Str,5);
						select(Pair_Head);
							when('T') Rec_T=input(Pair_Body,8.);
							when('P') Rec_P=Pair_Body;
							when('I') Rec_I=Pair_Body;
							when('U') Rec_U=Pair_Body;
							when('A') Rec_A=Pair_Body;
							when('B') Rec_B=Pair_Body;
							when('V') Rec_V=Pair_Body;
							when('W') Rec_W=Pair_Body;
							when('N') Rec_N=Pair_Body;
							when('C') Rec_C=Pair_Body;
							otherwise Rec_Other=Pair_Body;
						end;
					end;
		output dir.recdata;
	end;
run;

/*第一次，先留个脚印*/
%if  &CountOfMacro=1 %then %do;
proc sql;
	create table dir.fullrecdata(compress=char)
	like dir.recdata;
	create table dir.fullnullrec(compress=char)
	like  dir.nullrecdata;
quit;
%end;

/*把每次发的奖金都上交*/
proc sql noprint;
	insert into dir.fullrecdata
	select * from dir.recdata;
	insert into dir.fullnullrec
	select * from dir.nullrecdata;
quit;
%end;
%mend;

%makesets

