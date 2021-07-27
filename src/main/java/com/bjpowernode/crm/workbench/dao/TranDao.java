package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int save(Tran t);

    int getTotalByCondition(Map<String, Object> map);

    List<Tran> getTranListByCondition(Map<String, Object> map);

    Tran getTranById(String id);

    int changeStage(Tran tr);

    int getTotal();

    List<Map<String, Object>> getCharts();

    int update(Tran t);

    Tran getSingleTranById(String id);

    int getTotalById(String[] ids);

    int delete(String[] ids);

    List<Tran> getTranListByCusid(String id);

    int getTotalByCustomerIds(String[] ids);

    int deleteByCustomerIds(String[] ids);

    List<Tran> getTranListByConid(String id);
}
