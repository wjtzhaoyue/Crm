package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.ContactsActivityRelation;

public interface ContactsActivityRelationDao {

     int deleteByAids(String[] ids) ;


    int getCountByAids(String[] ids);

    int save(ContactsActivityRelation contactsActivityRelation);

    int getCountByCids(String[] ids);

    int deleteByCids(String[] ids);

    boolean Unbind(String id);
}
