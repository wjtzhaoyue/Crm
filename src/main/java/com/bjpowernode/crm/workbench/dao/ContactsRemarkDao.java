package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.ContactsRemark;
import com.bjpowernode.crm.workbench.domain.CustomerRemark;

import java.util.List;

public interface ContactsRemarkDao {


    int save(ContactsRemark contactsRemark);


    int getCountByCids(String[] ids);

    int deleteByCids(String[] ids);

    List<ContactsRemark> getRemarkListByCid(String contactsId);

    int saveRemark(ContactsRemark cr);

    int updateRemark(ContactsRemark cr);

    int deleteById(String id);
}
