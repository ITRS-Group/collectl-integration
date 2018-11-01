my ($itrsFilename, $cpuHeaderPrinted, $netHeaderPrinted, $prcHeaderPrinted, $memHeaderPrinted, $ibHeaderPrinted, $subsysfilt);
sub itrsInit
    {
        $cpuHeaderPrinted   = 1;
        $netHeaderPrinted   = 1;
        $prcHeaderPrinted   = 1;
        $memHeaderPrinted   = 1;
        $ibHeaderPrinted    = 1;
        $subsysfilt         = '';

        foreach $subsyscheck (split //, $userSubsys)
        {
            if ($subsyscheck=~/[^CjmNXZ]/)
            {
                print "Warning: -s$subsyscheck is not supported,ignoring\n";
            }
            else
            {
                $subsysfilt.=$subsyscheck;
            }
        }
        $subsys = $subsysfilt
    }
  
sub itrs
{
    ###############################
    # options
    ###############################
    $itrsFilename="output";
    $itrsFilename=$filename if $filename ne '';
    $datetime='';
    #$timestamp = strftime "%Y-%m-%e:%H:%M:%S", localtime;
    $timestamp = strftime "%H:%M:%S", localtime;

    if ($options=~/[dDTm]/)
    {
        ($ss, $mm, $hh, $mday, $mon, $year)=localtime($lastSecs[0]);
        $datetime.=".$usecs"                                                          if ($options=~/m/);
        $datetime.=" "; 
    }
  
   
  #######################################################################################################
  # CPU data, -sC
  #######################################################################################################
    if ($subsys=~/C/)
    {
        # set up output.
        my $cpuLine='';
        my $cpuFilename=sprintf("%s\_cpu",$itrsFilename);
        open (CPU, ">>$cpuFilename") or die "Could not open '$cpuFilename' for writing [$!]";
        
        if ($cpuHeaderPrinted==0)
        {
            $cpuHeader=sprintf("#CPU,userP,niceP,sysP,waitP,irqP,softP,stealP,idleP,intrptTot,time\n");
            print CPU $cpuHeader;
            $cpuHeaderPrinted=1;
        }

        for (my $i=0; $i<$NumCpus; $i++)
        {
            $cpuLine=sprintf("cpu%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%s\n",
                              $i,             $userP[$i],   $niceP[$i], 
                              $sysP[$i],      $waitP[$i],   $irqP[$i], 
                              $softP[$i],     $stealP[$i],  $idleP[$i], 
                              $intrptTot[$i], $timestamp);

            print CPU $cpuLine;
        }

        close (CPU);

    }

  #######################################################################################################
  # NET data, -sN
  #######################################################################################################
    if ($subsys=~/N/)
    {
        my $netLine='';
        my $netFilename=sprintf("%s\_net",$itrsFilename);
        open (NET, ">>$netFilename") or die "Could not open '$netFilename' for writing [$!]";
	if ($netHeaderPrinted==0)
        {
            $netHeader=sprintf("netName,netRxKB,netRxPkt,SizeI,netRxMlt,netRxCmp,netRxErr,netTxKB,netTxPkt,SizeO,netTxCmp,netTxErr,time");
            print NET $netHeader;
            $netHeaderPrinted=1;
        }
	
        for ($i=0; $i<scalar(@netName); $i++)
        {
            if ($netName[$i] ne '') # Gets rid of 'empty' interfaces being reported with no actual stats.
            {
                $netName[$i]=~ s/://;
                $SizeI=$netRxPkt[$i] ? $netRxKB[$i]*1024/$netRxPkt[$i] : 0;
                $SizeO=$netTxPkt[$i] ? $netTxKB[$i]*1024/$netTxPkt[$i] : 0;
                $netLine=sprintf("%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%s\n",
                                  $netName[$i],     $netRxKB[$i],   $netRxPkt[$i], 
                                  $SizeI,           $netRxMlt[$i],  $netRxCmp[$i], 
                                  $netRxErr[%d],    $netTxKB[$i],   $netTxPkt[$i],
                                  $SizeO,           $netTxCmp[$i],  $netTxErr[%d], 
                                  $timestamp);
                print NET $netLine;
            }
        }
        close (NET);
  
  }

    
  #######################################################################################################
  # PRC data, -sZ
  #######################################################################################################
    if ($subsys=~/Z/)
    {
        my $prcLine='';
        my $prcFilename=sprintf("%s\_prc",$itrsFilename);
        open (PRC, ">>$prcFilename") or die "Could not open '$prcFilename' for writing [!$]";
        if ($prcHeaderPrinted==0)
        {
            $prcHeader=sprintf("procCmd,key,procUser,procPri,procPpid,procTCount,procState,procVmSize,procVmRSS,procCPU,procSTime,procUTime,pct,AccuTime,procRKB,procWKB,procMajFlt,procMinFlt,timestamp\n");
            print PRC $prcHeader;
            $prcHeaderPrinted=1;
        }
        foreach  $key (sort(keys %procIndexes))
        {
            my $i=$procIndexes{$key};
            $pct=($procSTime[$i]+$procUTime[$i])/$interval2SecsReal;
            $AccuTime=cvtT2($procSTimeTot[$i]+$procUTimeTot[$i],1);
            $prcLine=sprintf("%s,%d,%s,%d,%d,%d,%s,%d,%d,%d,%s,%s,%d,%s,%d,%d,%d,%d,%s\n", 
                              $procCmd[$i],     $key,                    $procUser[$i], 
                              $procPri[$i],     $procPpid[$i],           $procTCount[$i], 
                              $procState[$i],   ($procVmSize[$i]/1024), ($procVmRSS[$i]/1024), 
                              $procCPU[$i],     cvtT1($procSTime[$i],1), cvtT1($procUTime[$i],1), 
                              $pct,             $AccuTime,               $procRKB[$i], 
                              $procWKB[$i],     $procMajFlt[%i],         $procMinFlt[%i], 
                              $timestamp);
            print PRC $prcLine;
        }
        close (PRC);
    }

    #######################################################################################################
    # MEM data, -sm
    #######################################################################################################

    if ($subsys=~/m/)
    {
        my $memLine='';
        my $memFilename=sprintf("%s\_mem",$itrsFilename);
        open (MEM, ">>$memFilename") or die "Could not open '$memFilename' for writing [!$]";
        if ($memHeaderPrinted==0)
        {
            $memHeader=sprintf("memTot,memUsed,memFree,memShared,memBuf,memCached,swapTotal,swapUsed,swapFree,swapin/intSecs,swapout/intSecs,memDirty,clean,laundry,memInact,pagein/intSecs,pageout/intSecs,pagefault/intSecs,pagemajfault/intSecs,memHugeTot,memHugeFree,memHugeRsvd,memSUnreclaim\n");
            print MEM $memHeader;
            $memHeaderPrinted=1;
        }
        $memline=sprintf("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%s\n",
                          $memTot,                $memUsed,           $memFree,
                          $memShared,             $memBuf,            $memCached,
                          $swapTotal,             $swapUsed,          $swapFree,
                          $swapin/$intSecs,       $swapout/$intSecs,  $memDirty,
                          $clean,                 $laundry,           $memInact,
                          $pagein/$intSecs,       $pageout/$intSecs,  $pagefault/$intSecs,
                          $pagemajfault/$intSecs, $memHugeTot,        $memHugeFree,
                          $memHugeRsvd,           $memSUnreclaim,     $timestamp);	
	print MEM $memline;
    }

    #######################################################################################################
    # INFINIBAND data, -sX
    #######################################################################################################
    if ($subsys=~/X/ && $NumHCAs)
    {
        my $ibLine='';
        my $ibFilename=sprintf("%s\_ib",$itrsFilename);
        open (IB, ">>$ibFilename") or die "Could not open '$ibFilename' for writing [!$]";
        if ($ibHeaderPrinted==0)
        {
            $ibHeader=sprintf("HCA,ibRx,ibTx,ibRxKB,ibTxKB,ibErrorsTot\n");
            print IB $ibHeader;
            $ibHeaderPrinted=1;
        }
        for ($i=0; $i<$NumHCAs; $i++)
        {
            $ibLine=sprintf("%d,%d,%d,%d,%d,%d,%s\n",
            $i,             $ibRx[$i],   
            $ibTx[$i],      $ibRxKB[$i], 
            $ibTxKB[$i],    $ibErrorsTot[$i],
            $timestamp);
        }
        print IB $ibLine
    }

}
1;
