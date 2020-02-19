########################################################################################
## Author:        Ian McCarthy
## Date Created:  5/29/2019
## Date Edited:   11/1/2019
## Notes:         R file to read in HCRIS data (1996 version of forms)
########################################################################################


########################################################################################
## List variables and locations
## -- This code forms a data.frame and tibble that consists of each variable of interest
##    and its location in the HCRIS forms. 
########################################################################################
library(tidyverse)
hcris.vars = NULL
hcris.vars = rbind(hcris.vars,c('beds','S300001','01200','0100','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_charges','G300000','00100','0100','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_discounts','G300000','00200','0100','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_operating_exp','G300000','00400','0100','numeric'))
hcris.vars = rbind(hcris.vars,c('ip_charges','G200000','00100','0100','numeric'))
hcris.vars = rbind(hcris.vars,c('icu_charges','G200000','01500','0100','numeric'))
hcris.vars = rbind(hcris.vars,c('ancillary_charges','G200000','01700','0100','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_discharges','S300001','00100','1500','numeric'))
hcris.vars = rbind(hcris.vars,c('mcare_discharges','S300001','00100','1300','numeric'))
hcris.vars = rbind(hcris.vars,c('mcaid_discharges','S300001','00100','1400','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_mcare_payment','E00A18A','01600','0100','numeric'))
hcris.vars = rbind(hcris.vars,c('secondary_mcare_payment','E00A18A','01700','0100','numeric'))
hcris.vars = rbind(hcris.vars,c('street','S200000','00100','0100','alpha'))
hcris.vars = rbind(hcris.vars,c('city','S200000','00101','0100','alpha'))
hcris.vars = rbind(hcris.vars,c('state','S200000','00101','0200','alpha'))
hcris.vars = rbind(hcris.vars,c('zip','S200000','00101','0300','alpha'))
hcris.vars = rbind(hcris.vars,c('county','S200000','00101','0400','alpha'))
colnames(hcris.vars)=c("variable","WKSHT_CD","LINE_NUM","CLMN_NUM","source")

path.raw = "/Volumes/Transcend/2020Spring/Econ 470/Econ 470 dataset/HW2-HCRIS"

########################################################################################
## Pull relevant data
## -- note: v1996 of HCRIS forms run through 2011 due to lags in processing and hospital
##    fiscal years
########################################################################################
for (i in 1998:2011) {
  HCRIS.alpha=read_csv(paste(path.raw,"/HospitalFY/hosp_alpha2552_96_",i,"_long.csv",sep=""))
  HCRIS.numeric=read_csv(paste(path.raw,"/HospitalFY/hosp_nmrc2552_96_",i,"_long.csv",sep=""))
  HCRIS.report=read_csv(paste(path.raw,"/HospitalFY/hosp_rpt2552_96_",i,".csv",sep=""))
  final.reports = HCRIS.report %>%
    select(report=rpt_rec_num, provider_number=prvdr_num, npi=npi, 
           fy_start=fy_bgn_dt, fy_end=fy_end_dt, date_processed=proc_dt, 
           date_created=fi_creat_dt, status=rpt_stus_cd) %>%
    mutate(year=i)
  HCRIS.alpha = HCRIS.alpha %>% rename(itm_val_num = alphnmrc_itm_txt)
  for (v in 1:nrow(hcris.vars)) {
    hcris.data=get(paste("HCRIS.",hcris.vars[v,5],sep=""))
    var.name=quo_name(hcris.vars[v,1])    
    val = hcris.data %>%
      filter(wksht_cd==hcris.vars[v,2], line_num==hcris.vars[v,3], clmn_num==hcris.vars[v,4]) %>%
      select(report=rpt_rec_num, !!var.name:=itm_val_num) 
    assign(paste("val.",v,sep=""),val)
    final.reports=left_join(final.reports, 
              get(paste("val.",v,sep="")),
              by="report")
  }
  assign(paste("final.reports.",i,sep=""),final.reports)
  if (i==1998) {
    final.hcris.v1996=final.reports.1998
  } else {
    final.hcris.v1996=rbind(final.hcris.v1996,get(paste("final.reports.",i,sep="")))
  }
  
}
