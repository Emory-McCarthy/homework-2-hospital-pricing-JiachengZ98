########################################################################################
## Author:        Ian McCarthy
## Date Created:  5/30/2019
## Date Edited:   11/1/2019
## Notes:         R file to read in HCRIS data (2010 version of forms)
########################################################################################


########################################################################################
## List variables and locations
## -- This code forms a data.frame and tibble that consists of each variable of interest
##    and its location in the HCRIS forms. 
########################################################################################

hcris.vars = NULL
hcris.vars = rbind(hcris.vars,c('beds','S300001','01400','00200','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_charges','G300000','00100','00100','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_discounts','G300000','00200','00100','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_operating_exp','G300000','00400','00100','numeric'))
hcris.vars = rbind(hcris.vars,c('ip_charges','G200000','00100','00100','numeric'))
hcris.vars = rbind(hcris.vars,c('icu_charges','G200000','01600','00100','numeric'))
hcris.vars = rbind(hcris.vars,c('ancillary_charges','G200000','01800','00100','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_discharges','S300001','00100','01500','numeric'))
hcris.vars = rbind(hcris.vars,c('mcare_discharges','S300001','00100','01300','numeric'))
hcris.vars = rbind(hcris.vars,c('mcaid_discharges','S300001','00100','01400','numeric'))
hcris.vars = rbind(hcris.vars,c('tot_mcare_payment','E00A18A','05900','00100','numeric'))
hcris.vars = rbind(hcris.vars,c('secondary_mcare_payment','E00A18A','06000','00100','numeric'))
hcris.vars = rbind(hcris.vars,c('street','S200001','00100','00100','alpha'))
hcris.vars = rbind(hcris.vars,c('city','S200001','00200','00100','alpha'))
hcris.vars = rbind(hcris.vars,c('state','S200001','00200','00200','alpha'))
hcris.vars = rbind(hcris.vars,c('zip','S200001','00200','00300','alpha'))
hcris.vars = rbind(hcris.vars,c('county','S200001','00200','00400','alpha'))
hcris.vars = rbind(hcris.vars,c('hvbp_payment','E00A18A','07093','00100','numeric'))
hcris.vars = rbind(hcris.vars,c('hrrp_payment','E00A18A','07094','00100','numeric'))
colnames(hcris.vars)=c("variable","WKSHT_CD","LINE_NUM","CLMN_NUM","source")

path.raw = "/Volumes/Transcend/2020Spring/Econ 470/Econ 470 dataset/HW2-HCRIS"

########################################################################################
## Pull relevant data
########################################################################################
for (i in 2010:2017) {
  HCRIS.alpha=read_csv(paste(path.raw,"/HospitalFY/hosp_alpha2552_10_",i,"_long.csv",sep=""))
  HCRIS.numeric=read_csv(paste(path.raw,"/HospitalFY/hosp_nmrc2552_10_",i,"_long.csv",sep=""))
  HCRIS.report=read_csv(paste(path.raw,"/HospitalFY/hosp_rpt2552_10_",i,".csv",sep=""))
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
  if (i==2010) {
    final.hcris.v2010=final.reports.2010
  } else {
    final.hcris.v2010=rbind(final.hcris.v2010,get(paste("final.reports.",i,sep="")))
  }
}

