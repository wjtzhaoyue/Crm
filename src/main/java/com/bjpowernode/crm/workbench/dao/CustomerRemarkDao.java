package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.CustomerRemark;

import java.util.List;

public interface CustomerRemarkDao {

    int save(CustomerRemark customerRemark);

    List<CustomerRemark> getRemarkListByCid(String customerId);

    int saveRemark(CustomerRemark cr);

    int updateRemark(CustomerRemark cr);

    int deleteRemarkById(String id);

    int getCountByCids(String[] ids);

    int deleteByCids(String[] ids);
}
