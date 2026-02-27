package com.sena.test.IRepository.IInventoryRepository;

import java.util.List;
import com.sena.test.Entity.Inventory.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryRepository extends JpaRepository <Category, Integer>{

    @Query(""
			+ "SELECT "
			+ "c "
			+ "FROM "
			+ "category c "
			+ "WHERE "
			+ "c.name_category like %?1%"
			)
	public List<Category>filterByNameCategory(String name_category);
}