package com.sena.test.IService;

import java.util.List;

import com.sena.test.Dto.RoleDto;
import com.sena.test.Entity.Role;

public interface IRoleService {

    public List<Role> findAll();
    public Role findById(int id_role);
    String update (int id, RoleDto roleDto);
    public List<Role> findByRole(String role);
    public String save(RoleDto r);
    public String delete(int id);
}