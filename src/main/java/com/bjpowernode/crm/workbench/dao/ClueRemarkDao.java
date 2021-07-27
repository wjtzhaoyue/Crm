package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    List<ClueRemark> getRemarkListByCid(String clueId);

    int updateRemark(ClueRemark cr);

    int deleteById(String id);

    int saveRemark(ClueRemark cr);


    List<ClueRemark> getListByClueId(String clueId);

    int delete(ClueRemark clueRemark);

    int getCountByCids(String[] ids);

    int deleteByCids(String[] ids);
}
