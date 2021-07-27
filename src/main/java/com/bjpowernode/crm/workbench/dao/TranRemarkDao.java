package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.TranRemark;

import java.util.List;

public interface TranRemarkDao {
    int saveRemark(TranRemark trr);

    List<TranRemark> getRemarkListByTid(String transactionId);

    int updateRemark(TranRemark trr);

    int deleteById(String id);

    int getTotalByIds(String[] ids);

    int deleteByIds(String[] ids);
}
