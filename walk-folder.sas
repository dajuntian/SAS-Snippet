%let path=E:\Data\data;	/*设置主目录*/
libname Dir "&path\sasDataSet";

/*读取每个文件的路径和文件名信息*/
data Dir.DirInfo(keep=ID PriDirName SecDirname);
	length ID $100 PriDirName $10 SecDirname $100;
	PriDirRc=filename("PriDir","&path\behavior");
	PriDirDid=dopen("PriDir");
	PriDirNum=dnum(PriDirDid);
	do i = 1 to PriDirNum;
		PriDirName=dread(PriDirDid,i);
		SecDirRc=filename("SecDir","&path\behavior\"||
			PriDirName);
		SecDirDid=dopen("SecDir");
		SecDirNum=dnum(SecDirDid);
		do j= 1 to SecDirNum;
			SecDirName=dread(SecDirDid,j);
			ID=scan(SecDirName,1,'_');
			output;
		end;
		SecDirRc=dclose(SecDirDid);
	end;
	PriDirRc=dclose(PriDirDid);
run;


