package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.vo.PaginationVO;
import com.bjpowernode.crm.workbench.domain.Contacts;
import com.bjpowernode.crm.workbench.domain.Customer;
import com.bjpowernode.crm.workbench.domain.CustomerRemark;
import com.bjpowernode.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    PaginationVO<Customer> pageList(Map<String, Object> map);

    boolean save(Customer customer);

    Map<String, Object> getUserListAndCustomer(String id);

    boolean update(Customer customer);

    Customer getCustomerById(String id);

    List<CustomerRemark> getRemarkListByCid(String customerId);

    boolean saveRemark(CustomerRemark cr);

    boolean updateRemark(CustomerRemark cr);

    boolean deleteRemark(String id);

    List<Tran> getTranListByCid(String id);

    List<Contacts> getContactsListByCid(String id);

    boolean deleteContacts(String id);

    boolean saveContactsAndPanDuan(Contacts contacts, String customerName);

    boolean delete(String[] ids);
}
