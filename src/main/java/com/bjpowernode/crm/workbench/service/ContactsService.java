package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.domain.ContactsRemark;
import com.bjpowernode.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface ContactsService {
    PaginationVO<Contacts> pageList(Map<String, Object> map);

    boolean save(Contacts contacts, String customerName);

    Map<String, Object> getUserListAndContacts(String id);

    boolean update(Contacts contacts, String customerName);

    boolean delete(String[] ids);

    Contacts detail(String id);

    List<ContactsRemark> getRemarkListByAid(String contactsId);

    boolean saveRemark(ContactsRemark cr);

    boolean updateRemark(ContactsRemark cr);

    boolean deleteRemark(String id);

    List<Tran> getTranListByCid(String id);


    List<Activity> getActivityListByCid(String id);

    boolean Unbind(String id);

    List<Activity> getActivityListByAids(String[] ids);

    //boolean saveActivity(List<Activity> aList);

    boolean saveClueActivityRelation(List<Activity> aList, String cid);

}
