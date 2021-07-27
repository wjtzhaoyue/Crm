package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationDao {


    int unbind(String id);

    int guanlian(ClueActivityRelation car);


    List<ClueActivityRelation> getListByClueId(String clueId);

    int delete(ClueActivityRelation clueActivityRelation);



    int getCountByCids(String[] ids);

    int deleteByCids(String[] ids);



    int getCountByAids(String[] ids);

    int deleteByAids(String[] ids);
}
