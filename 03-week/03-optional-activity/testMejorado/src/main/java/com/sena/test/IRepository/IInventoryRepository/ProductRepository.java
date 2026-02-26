package com.sena.test.IRepository.IInventoryRepository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import com.sena.test.Entity.Inventory.Product;

@Repository
public interface ProductRepository extends JpaRepository <Product, Integer>{

    @Query(""
			+ "SELECT "
			+ "p "
			+ "FROM "
			+ "product p "
			+ "WHERE "
			+ "p.name_product like %?1%"
			)
	public List<Product>filterByNameProduct(String name_product);
}
