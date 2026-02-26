package com.sena.test.IService.IInventoryService;

import java.util.List;
import com.sena.test.Dto.InventoryDto.ProductDto;
import com.sena.test.Entity.Inventory.Product;

public interface IProductService {

    public List<Product>findAll();
    public Product findById(int id);
    String update(int id, ProductDto ProductDto);
    public List<Product> filterByNameProduct(String name_product);
    public String save(ProductDto p);
    public String delete(int id);
}
