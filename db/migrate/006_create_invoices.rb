class CreateInvoices < ActiveRecord::Migration
  def self.up
      sql_code = <<-END
      CREATE TABLE `invoices`(`id` INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
        `name` VARCHAR(45) NOT NULL,
        `notes` TEXT,
        `client_id` INTEGER UNSIGNED NOT NULL,
        `user_id` INTEGER UNSIGNED NOT NULL,
        `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `is_issued` BOOLEAN NOT NULL DEFAULT 0,
        `issued_at` TIMESTAMP NULL,
        PRIMARY KEY(`id`),
        UNIQUE `UNIQUE`(`name`));
      ALTER TABLE `activities` ADD COLUMN `invoice_id` INTEGER UNSIGNED
      END
      sql_code.split(';').each do |stmt|
      execute stmt
    end
  end

  def self.down
    execute "DROP TABLE `invoices`;"
    execute "ALTER TABLE `activities` DROP COLUMN `invoice_id`;"
  end
end
