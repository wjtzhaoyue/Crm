package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.domain.*;

import java.util.List;
import java.util.Map;

public interface TranService {
    List<Activity> getActivityByName(String aname);


    List<Contacts> getContactsByName(String cname);

    List<String> getCustomerName(String name);

    boolean save(Tran t, String customerName);

    PaginationVO<Tran> pageList(Map<String, Object> map);

    Tran getTranById(String id);

    List<TranHistory> getHistoryListById(String tranId);

    boolean changeStage(Tran tr);

    Map<String, Object> getCharts();

    boolean update(Tran t, String customerName);

    Tran getSingleTranById(String id);

    boolean delete(String[] ids);

    boolean saveRemark(TranRemark trr);

    List<TranRemark> getRemarkListByTid(String transactionId);

    boolean updateRemark(TranRemark trr);

    boolean deleteRemark(String id);



}
