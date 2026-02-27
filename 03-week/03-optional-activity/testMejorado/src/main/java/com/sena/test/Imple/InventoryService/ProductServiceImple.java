package com.sena.test.Imple.InventoryService;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.sena.test.Dto.InventoryDto.ProductDto;
import com.sena.test.Entity.Inventory.Product;
import com.sena.test.IRepository.IInventoryRepository.ProductRepository;
import com.sena.test.IService.IInventoryService.IProductService;

@Service
public class ProductServiceImple implements IProductService{

    @Autowired
    private ProductRepository repo;

    @Override
    public List<Product>findAll(){
        return repo.findAll();
    }

    @Override
    public Product findById(int id){
        return repo.findById(id).orElse(null);
    }

    @Override
    public String update(int id, ProductDto productDto){
        Product product = repo.findById(id).orElse(null);

        if(product == null){
            return "Producto no encontrado";
        }

        product.setName_product(productDto.getName_product());
        product.setPrice(productDto.getPrice());
        product.setDescription(productDto.getDescription());

        repo.save(product);
        return "Producto actualizado correctamente";
    }

    public Product dtoToEntity(ProductDto productDto){
        return new Product(
            productDto.getId(),
            productDto.getName_product(),
            productDto.getPrice(),
            productDto.getDescription()
        );
    }

    public Product entityToDto(Product product){
        return new Product(
            product.getId(),
            product.getName_product(),
            product.getPrice(),
            product.getDescription()
        );
    }

    @Override
    public List<Product> filterByNameProduct(String name_product){
        return repo.filterByNameProduct(name_product);
    }

    @Override
    public String save(ProductDto p){
        Product product = dtoToEntity(p);
        repo.save(product);
        return "El producto se guardo exitosamente";
    }

    @Override
    public String delete(int id){
        repo.deleteById(id);
        return null;
    }
}